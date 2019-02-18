#!/usr/bin/env bash

#
# Will install and compile required libraries
#

# Print commands and their arguments as they are executed.
set -x
# Exit on any error
set -e

function compile_php_extension_from_source() {
    git clone "$1"
    cd "./$2"
    git checkout "$3"
    phpize
    ./configure
    make
    make install
    cd ..
    rm -rf "./$2"
}

function compile_lib_from_source() {
    git clone "$1"
    cd "$2"
    git checkout "$3"
    sh autogen.sh
    ./configure
    make
    # Tests took too much time
    # make check
    # make verify
    make install
    cd ..
    rm -rf "./$2"
}

apt-get update
apt-get install build-essential libssl-dev git libtool m4 automake psmisc gnupg libicu-dev zlib1g-dev zip unzip -y
curl -sL https://deb.nodesource.com/setup_8.x | bash -
apt-get install nodejs -y

git clone https://github.com/torinaki/wrk.git && cd wrk && git checkout lua-plot-report
make && rm -f /usr/local/bin/wrk && cp wrk /usr/local/bin && cd ..
rm -rf ./wrk

compile_lib_from_source "https://github.com/libuv/libuv.git" "libuv" "v1.11.0"
compile_lib_from_source "https://github.com/libevent/libevent.git" "libevent" "release-2.1.8-stable"

docker-php-ext-configure pcntl
docker-php-ext-install pcntl
docker-php-ext-enable pcntl
docker-php-ext-configure intl
docker-php-ext-install intl
docker-php-ext-enable intl
docker-php-ext-install sockets
docker-php-source extract

if php -v | egrep -q "^PHP 7.(1|2|3)"; then
    compile_php_extension_from_source "https://bitbucket.org/osmanov/pecl-ev.git" "pecl-ev" "1.0.5"
    compile_php_extension_from_source "https://bitbucket.org/osmanov/pecl-event.git" "pecl-event" "2.4.2"
else
    echo "Skip EV installation"
fi

compile_php_extension_from_source "https://github.com/swoole/swoole-src.git" "swoole-src" "v4.2.13"
compile_php_extension_from_source "https://github.com/bwoebi/php-uv.git" "php-uv" "master"

docker-php-source delete
sh ./build/install-local.sh
chmod +x ./start_benchmark.sh

rm composer.phar
