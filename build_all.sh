#!/bin/bash

# Resolved once and shared across all builds below so all 4 variants use the identical
# pokeemerald/agbcc commit (and only the first one actually re-clones; the rest hit cache),
# instead of each build.sh call independently re-resolving "latest" and potentially landing on
# a different commit if something lands upstream mid-batch.
. "$(dirname "$0")/resolve_commits.sh"
export POKEEMERALD_COMMIT_HASH
export AGBCC_COMMIT_HASH

# Builds the ROM using agbcc compiler to produce
# sha1 f3ae088181bf583e55daf962a92bb46f4f1d07b7
./build.sh

# Builds the ROM with fixes for bugs defined in the code
./build.sh --bugfix

# Builds the ROM using a modern compiler instead of agbcc
./build.sh --modern

# Builds the ROM using both bugfixes and modern compiler
./build.sh --bugfix --modern

# Compares the sha1 of built pokeemerald.gba file
./sha1_check.sh
