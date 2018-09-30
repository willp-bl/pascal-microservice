#!/usr/bin/env bash

set -eu

ROOT_DIR="$(dirname "$0")"
cd "$ROOT_DIR"

if [ ! -d brookframework ]; then
    git clone https://github.com/silvioprog/brookframework.git
fi

mkdir -p bin
fpc -opascalmicroservice.exe -FEbin -Fubrookframework/core -Fubrookframework/brokers -Fibrookframework/includes src/pascalmicroservice.lpr
cp bin/pascalmicroservice.exe .
