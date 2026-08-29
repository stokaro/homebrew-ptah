# homebrew-ptah

The Homebrew tap for [Ptah](https://github.com/stokaro/ptah), open-source
database change management for schemas, migrations, data, and persistent
inference state.

Two formulas live here. `ptah` is the released version; `ptah-edge` is the
current `master`.

## Install a release

```bash
brew install stokaro/ptah/ptah
```

That form taps this repository on first use. To tap it explicitly:

```bash
brew tap stokaro/ptah
brew install ptah
```

Upgrade with `brew update && brew upgrade ptah`.

## Install edge

`ptah-edge` tracks the tip of `master`, the same source the
[edge documentation](https://stokaro.github.io/ptah/edge/) is built from. It is
head-only, so the `--HEAD` flag is required:

```bash
brew install --HEAD stokaro/ptah/ptah-edge
```

It has no bottle and is compiled on your machine. Homebrew installs Go as a
build dependency, and the build took 41 seconds on an arm64 Mac with a cold Go
build cache, 11 with a warm one.

The binaries report the commit they came from, so you can tell exactly what you
are running:

```console
$ ptah version
Version: HEAD-6eb18bd
Commit: 6eb18bd8519aedcbb3a5a9c97bc2bffdd711cf3d
Date: 2026-08-29T16:20:58Z
Go: go1.27.0
Platform: darwin/arm64
```

`master` moves many times a day, and Homebrew does not re-resolve a head
formula unless you ask it to. Pick up a newer `master` with:

```bash
brew upgrade --fetch-HEAD ptah-edge
```

Edge is the development tip, not a release: it carries commands and behavior no
released version has, and it is not covered by the release verification that a
tag goes through.

## Only one of the two at a time

Both formulas install the same three binaries, so they conflict and Homebrew
refuses to have both linked. Switch with:

```bash
brew uninstall ptah && brew install --HEAD stokaro/ptah/ptah-edge   # release -> edge
brew uninstall ptah-edge && brew install stokaro/ptah/ptah          # edge -> release
```

## What the formulas install

| Binary | What it is |
| --- | --- |
| `ptah` | the native command-line interface |
| `ptah-compat` | a drop-in replacement for the Atlas CLI |
| `ptah-ls` | the language server |

Each one reports its build:

```bash
ptah version
ptah-compat version
ptah-ls --version
```

## Which file is generated and which is not

`Formula/ptah.rb` is generated. Its source is the `brews:` section of
[`.goreleaser.yaml`](https://github.com/stokaro/ptah/blob/master/.goreleaser.yaml)
in the Ptah repository, and the `Release` workflow pushes the rendered file here
on every version tag. Editing it here changes nothing beyond the next release,
which overwrites it.

`Formula/ptah-edge.rb` is written by hand. GoReleaser writes one path and only
that one, so this file survives a release — and nothing regenerates it either.
When the release build changes (ldflags, `CGO_ENABLED`, the set of binaries),
change it here too, or the edge build stops matching the release it is the edge
of.

That coupling is checked rather than merely asked for.
[`scripts/check-edge-matches-release.sh`](scripts/check-edge-matches-release.sh)
reads ptah's `.goreleaser.yaml` and requires the formula to still repeat it: the
same three binaries, the same `buildinfo` ldflags, the same `CGO_ENABLED=0`, and
`-trimpath` by way of `std_go_args`. The change that breaks it is made in the
other repository, where nothing can see this file, so the check runs on a daily
schedule as well as on every push here. It fails rather than skips when ptah's
config cannot be read.

## Other ways to install Ptah

Homebrew is one route. The
[install page](https://stokaro.github.io/ptah/edge/start/install/) covers the
one-command installer for Linux, macOS, and Windows, the release archives for
amd64 and arm64, and how to verify a download against the signed checksums.
Container images are published to `ghcr.io/stokaro/ptah`.

## Issues

Report a problem with either formula, and everything else about Ptah, in the
[Ptah issue tracker](https://github.com/stokaro/ptah/issues). This repository
carries no code of its own.

## License

MIT, the same as Ptah. See [LICENSE](LICENSE).
