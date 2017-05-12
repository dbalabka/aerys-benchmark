#!/usr/bin/env bash

docker build -t aerys-benchmark:php70 -f ./build/php70/Dockerfile . \
&& docker build -t aerys-benchmark:php71 -f ./build/php71/Dockerfile . \
&& docker build -t aerys-benchmark:php72jit -f ./build/php72jit/Dockerfile .