#!/bin/bash

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
