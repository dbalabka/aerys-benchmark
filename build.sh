#!/usr/bin/env bash

# Print commands and their arguments as they are executed.
set -x
# Exit on any error
set -e

docker build -t aerys-benchmark:php71 -f ./build/php71/Dockerfile .
docker build -t aerys-benchmark:php72 -f ./build/php72/Dockerfile .
docker build -t aerys-benchmark:php73 -f ./build/php73/Dockerfile .
docker build -t aerys-benchmark:php74jit -f ./build/php74jit/Dockerfile .
docker build -t aerys-benchmark:php8jit -f ./build/php8jit/Dockerfile . || echo "Skip PHP 8. Docker image build fail!"
