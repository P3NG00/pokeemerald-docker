#!/bin/bash

if [ -f "./pokeemerald.sha1" ]; then
    # Compares the sha1 of built pokeemerald.gba file
    sha1sum --check ./pokeemerald.sha1
else
    echo "Missing 'pokeemerald.sha1'"
    exit 1
fi
