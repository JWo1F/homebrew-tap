# JWo1F/homebrew-tap

Homebrew formulae for [icofon](https://github.com/JWo1F/icofon) and
[serv](https://github.com/JWo1F/serv).

```bash
brew tap jwo1f/tap
brew install icofon
brew install serv
```

Or in one line each, without tapping first:

```bash
brew install jwo1f/tap/icofon
brew install jwo1f/tap/serv
```

## Formulae

| Formula | What it is |
| --- | --- |
| `icofon` | Build an icon font (WOFF2/WOFF/TTF + CSS) from a folder of SVG files |
| `serv` | A small development server for static sites and single-page apps |

Both install a prebuilt binary from the project's own GitHub release, so there
is no Rust toolchain to pull in and nothing to compile. Covered platforms are
macOS on Apple Silicon and Intel, and Linux on arm64 and x86_64 — the Linux
builds are statically linked against musl, so they run on any distribution.

## Updating a formula

Each tool has a workflow of its own, run by hand from the Actions tab:

| Workflow | What it does |
| --- | --- |
| `icofon` | Points `Formula/icofon.rb` at a release of icofon |
| `serv` | Points `Formula/serv.rb` at a release of serv |

Run one with no input and it takes that project's latest release; give it a
version to pin to that one instead. It downloads the four release archives,
rewrites the formula's version and its four url/sha256 pairs, installs and
tests the result on Apple Silicon, Intel macOS and x86_64 Linux, and only then
commits. Nothing lands unless it installed and passed the formula's own test.

Released under the MIT license, same as the tools themselves.
