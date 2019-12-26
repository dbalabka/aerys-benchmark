#!/usr/bin/env bash

# Print commands and their arguments as they are executed.
set -x
# Exit on any error
set -e

docker build -t aerys-benchmark:php73 -f ./build/php73/Dockerfile .
docker build -t aerys-benchmark:php74 -f ./build/php74/Dockerfile .
docker build -t aerys-benchmark:php80 -f ./build/php80/Dockerfile . || echo "Skip PHP 8. Docker image build fail!"
