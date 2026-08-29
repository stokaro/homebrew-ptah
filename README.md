# homebrew-ptah

The Homebrew tap for [Ptah](https://github.com/stokaro/ptah), open-source
database change management for schemas, migrations, data, and persistent
inference state.

## Install

```bash
brew install stokaro/ptah/ptah
```

That form taps this repository on first use. To tap it explicitly:

```bash
brew tap stokaro/ptah
brew install ptah
```

## What the formula installs

The `ptah` formula installs all three Ptah binaries from one release archive:

| Binary | What it is |
| --- | --- |
| `ptah` | the native command-line interface |
| `ptah-compat` | a drop-in replacement for the Atlas CLI |
| `ptah-ls` | the language server |

Each one reports the release it came from:

```bash
ptah version
ptah-compat version
ptah-ls --version
```

## Upgrade

```bash
brew update
brew upgrade ptah
```

## Where `Formula/ptah.rb` comes from

The formula is generated, not written by hand. Its source is the `brews:`
section of
[`.goreleaser.yaml`](https://github.com/stokaro/ptah/blob/master/.goreleaser.yaml)
in the Ptah repository, and the `Release` workflow pushes the rendered file here
on every version tag. Editing it in this repository changes nothing beyond the
next release, which overwrites it — a change to what the formula installs
belongs in that file instead.

## Other ways to install Ptah

Homebrew is one route. The
[install page](https://stokaro.github.io/ptah/edge/start/install/) covers the
one-command installer for Linux, macOS, and Windows, the release archives for
amd64 and arm64, and how to verify a download against the signed checksums.
Container images are published to `ghcr.io/stokaro/ptah`.

## Issues

Report a problem with the formula, and everything else about Ptah, in the
[Ptah issue tracker](https://github.com/stokaro/ptah/issues). This repository
carries no code of its own.

## License

MIT, the same as Ptah. See [LICENSE](LICENSE).
