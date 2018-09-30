#!/usr/bin/env bash

set -eu

ROOT_DIR="$(dirname "$0")"
cd "$ROOT_DIR"

docker build -t fpc-build .
docker run -it --rm -v "$(pwd)/:/pascal-microservice" -p 4321:4321 fpc-build

