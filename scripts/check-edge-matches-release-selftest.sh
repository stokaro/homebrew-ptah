#!/usr/bin/env bash
# Proves check-edge-matches-release.sh reports each drift it claims to catch.
#
# A gate is only worth its run time if it fails on the thing it exists to
# find. Every coupling below is broken once, on a copy, and the gate is
# required to notice; the pair is then checked unmutated, so a gate that
# simply always failed would be caught here too.
#
# Nothing here touches the network: both inputs are passed in.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$here/.." && pwd)"
check="$here/check-edge-matches-release.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

curl -fsSL --retry 3 --retry-delay 2 \
	-o "$work/goreleaser.yaml" \
	"https://raw.githubusercontent.com/stokaro/ptah/master/.goreleaser.yaml" \
	|| { echo "selftest: could not fetch the release config" >&2; exit 1; }

failures=0

run() { # run <name> <expected-exit> <config> <formula>
	local name="$1" want="$2" config="$3" formula="$4" got=0
	PTAH_GORELEASER_CONFIG="$config" PTAH_EDGE_FORMULA="$formula" \
		"$check" >/dev/null 2>&1 || got=$?
	if [ "$got" -eq 0 ] && [ "$want" -eq 0 ]; then
		printf '  ok    %s\n' "$name"
	elif [ "$got" -ne 0 ] && [ "$want" -ne 0 ]; then
		printf '  ok    %s (rejected)\n' "$name"
	else
		printf '  FAIL  %s: exit %s, wanted %s\n' "$name" "$got" "${want}"
		failures=$((failures + 1))
	fi
}

base_config="$work/goreleaser.yaml"
base_formula="$repo_root/Formula/ptah-edge.rb"

# The control. Everything below mutates one thing away from this.
run "unmutated pair passes" 0 "$base_config" "$base_formula"

mutate() { # mutate <file> <sed-expr> -> path
	local out="$work/$RANDOM.$$.mutant"
	sed "$2" "$1" > "$out"
	printf '%s' "$out"
}

run "release gains a fourth binary" 1 \
	"$(mutate "$base_config" 's|^    binary: ptah-ls$|    binary: ptah-ls\n    binary: ptah-newcmd|')" \
	"$base_formula"

run "formula drops a binary" 1 "$base_config" \
	"$(mutate "$base_formula" 's|%w\[ptah ptah-compat ptah-ls\]|%w[ptah ptah-compat]|')"

run "formula loses the Commit stamp" 1 "$base_config" \
	"$(mutate "$base_formula" '/buildinfo\.Commit=/d')"

run "formula stops disabling cgo" 1 "$base_config" \
	"$(mutate "$base_formula" '/ENV\["CGO_ENABLED"\]/d')"

run "release stops asking for cgo-off" 1 \
	"$(mutate "$base_config" '/CGO_ENABLED=0/d')" "$base_formula"

run "formula loses trimpath and std_go_args" 1 "$base_config" \
	"$(mutate "$base_formula" 's|std_go_args(ldflags: ldflags, output: bin/cmd)|"-o", bin/cmd|')"

: > "$work/empty"
run "empty release config" 1 "$work/empty" "$base_formula"
run "missing release config" 1 "$work/does-not-exist" "$base_formula"

run "release config the parser cannot read" 1 \
	"$(mutate "$base_config" '/binary:/d')" "$base_formula"

# The discriminating control: the test block carries its own %w[...] list, and
# the gate must read the build loop's. Changing only the test block's list must
# NOT be reported, or the gate is matching whichever list it met first.
run "test block's own list is not the coupled one" 0 "$base_config" \
	"$(mutate "$base_formula" 's|%w\[ptah ptah-compat\]\.each|%w[ptah].each|')"

if [ "$failures" -ne 0 ]; then
	echo "selftest: $failures case(s) did not behave as required" >&2
	exit 1
fi
echo "check-edge-matches-release selftest: OK"
