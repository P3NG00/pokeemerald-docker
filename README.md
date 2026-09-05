# pokeemerald Dockerfile

This repo contains the Dockerfile I use to build 4 variants of the pret/pokeemerald repo:

| | agbcc | modern |
|-|-|-|
| regular | :white_check_mark: | :white_check_mark: |
| bugfixes | :white_check_mark: | :white_check_mark: |

The `build.sh` script can be run as normal to build the regular ROM.
It also accepts `--bugfix` and `--modern` or both combined to build how you want.

The Dockerfile accepts two optional arguments:

- `POKEEMERALD_COMMIT_HASH` – the commit of the pokeemerald repo to check out.
- `AGBCC_COMMIT_HASH` – the commit of the agbcc repo to check out.

`build.sh`/`build_all.sh` resolve these to each repo's latest commit and pass them in
automatically, so builds always pick up new upstream commits. Building the Containerfile
directly (bypassing those scripts) without passing `--build-arg` for these will only resolve
"latest" on the first build; a rebuild afterwards reuses the cached layer from that first build
rather than re-checking upstream, unless you pass `--no-cache` or supply the args yourself.

Example: `podman build --build-arg POKEEMERALD_COMMIT_HASH=<hash> --build-arg AGBCC_COMMIT_HASH=<hash> ...`

Thank you to the Pokemon-Reverse-Engineering-Tools Team for your hard work.

~ BryantF https://BryantF.xyz/
