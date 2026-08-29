#!/usr/bin/env bash
# Keeps Formula/ptah-edge.rb in step with how stokaro/ptah builds a release.
#
# Formula/ptah.rb is generated: GoReleaser renders it from the `brews:` section
# of ptah's .goreleaser.yaml and pushes it on every version tag. Formula
# ptah-edge.rb is written by hand, because GoReleaser's `brews:` block has no
# field for a Homebrew `head` and a release run overwrites ptah.rb whole.
#
# GoReleaser writes that one path and no other, so the hand-written file
# survives a release -- and nothing regenerates it either. It repeats four facts
# from the release build, and each one can move on the ptah side without
# anything here noticing: an edge binary that was compiled with cgo, or that
# lost a stamped version, or that is missing a fourth command the release now
# ships, still installs and still runs. It just stops being the edge of what
# ships, silently.
#
# So this reads ptah's config and asserts the formula still repeats it. A
# failure means one of the two files moved and the other did not; fix whichever
# is behind.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
formula="${PTAH_EDGE_FORMULA:-$repo_root/Formula/ptah-edge.rb}"
config="${PTAH_GORELEASER_CONFIG:-}"
source_url="https://raw.githubusercontent.com/stokaro/ptah/master/.goreleaser.yaml"

fail() { echo "check-edge-matches-release: $*" >&2; exit 1; }

[ -f "$formula" ] || fail "$formula is missing"

# A gate that cannot read one of its two inputs must not report success. An
# unreachable config is a failed check, never a skipped one.
if [ -z "$config" ]; then
	tmp="$(mktemp)"
	trap 'rm -f "$tmp"' EXIT
	curl -fsSL --retry 3 --retry-delay 2 -o "$tmp" "$source_url" \
		|| fail "could not fetch $source_url"
	config="$tmp"
fi
[ -s "$config" ] || fail "the release config at $config is empty"

# --- what the release build says ---------------------------------------------

release_binaries="$(awk '/^[[:space:]]+binary:[[:space:]]/ { print $2 }' "$config" | sort -u)"
[ -n "$release_binaries" ] || fail "found no 'binary:' entries in the release config; the parser is stale"

release_symbols="$(grep -oE '\-X [A-Za-z0-9./_-]+\.[A-Za-z]+=' "$config" \
	| sed 's/^-X //; s/=$//' | sort -u)"
[ -n "$release_symbols" ] || fail "found no '-X pkg.Symbol=' ldflags in the release config; the parser is stale"

# --- what the edge formula says ----------------------------------------------

# The %w[...] list the build loop iterates, not the one the test block does.
formula_binaries="$(awk '
	/%w\[/ { list = $0; next }
	/system "go", "build"/ && list != "" {
		match(list, /%w\[[^]]*\]/)
		body = substr(list, RSTART + 3, RLENGTH - 4)
		print body
		exit
	}
	{ if ($0 !~ /^[[:space:]]*$/) list = "" }
' "$formula" | tr ' ' '\n' | sed '/^$/d' | sort -u)"
[ -n "$formula_binaries" ] || fail "could not find the build loop's %w[...] list in $formula"

# --- the four couplings -------------------------------------------------------

if [ "$release_binaries" != "$formula_binaries" ]; then
	echo "check-edge-matches-release: the two builds ship different binaries" >&2
	echo "  release config: $(echo "$release_binaries" | tr '\n' ' ')" >&2
	echo "  edge formula:   $(echo "$formula_binaries" | tr '\n' ' ')" >&2
	exit 1
fi

while read -r symbol; do
	grep -qF -- "-X ${symbol}=" "$formula" \
		|| fail "the release stamps ${symbol} and the edge formula does not"
done <<< "$release_symbols"

if grep -qF 'CGO_ENABLED=0' "$config"; then
	grep -qF 'ENV["CGO_ENABLED"] = "0"' "$formula" \
		|| fail 'the release builds with CGO_ENABLED=0 and the edge formula does not set it'
else
	grep -qF 'ENV["CGO_ENABLED"] = "0"' "$formula" \
		&& fail 'the edge formula forces CGO_ENABLED=0 and the release config no longer asks for it'
fi

if grep -qF -- '-trimpath' "$config"; then
	grep -qE 'std_go_args|-trimpath' "$formula" \
		|| fail 'the release builds with -trimpath and the edge formula neither passes it nor uses std_go_args'
fi

echo "edge formula matches the release build: $(echo "$release_binaries" | tr '\n' ' ')"
