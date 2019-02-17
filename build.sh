#!/usr/bin/env bash

docker build -t aerys-benchmark:php71 -f ./build/php71/Dockerfile . \
&& docker build -t aerys-benchmark:php72 -f ./build/php72/Dockerfile . \
&& docker build -t aerys-benchmark:php73 -f ./build/php73/Dockerfile . \
&& docker build -t aerys-benchmark:php8jit -f ./build/php8jit/Dockerfile .
