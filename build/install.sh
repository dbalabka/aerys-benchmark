#!/usr/bin/env bash

#
# Will install and compile required libraries
#

apt-get update \
&& curl -sL https://deb.nodesource.com/setup_7.x | bash - \
&& apt-get install build-essential libssl-dev git libtool m4 automake psmisc nodejs -y \
&& git clone https://github.com/wg/wrk.git && cd wrk \
&& make \
&& cd ../bin && rm wrk && cp ../wrk/wrk wrk && cd .. \
&& git clone https://github.com/libuv/libuv.git && cd libuv && git checkout v1.11.0 \
&& sh autogen.sh && ./configure && make `#&& make check` \
&& make install && cd .. \
&& git clone https://github.com/libevent/libevent.git && cd libevent && git checkout release-2.1.8-stable \
&& sh autogen.sh && ./configure && make `#&& make verify` \
&& make install && cd .. \
&& docker-php-ext-install sockets \
&& docker-php-source extract \
&& pecl channel-update pecl.php.net \
&& printf "\n\n\n\n\n\n\n" | pecl install ev-1.0.4 event-2.3.0 uv-0.1.2 \
&& docker-php-source delete \
&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php -r "if (hash_file('SHA384', 'composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
&& php composer-setup.php \
&& php -r "unlink('composer-setup.php');" \
&& php composer.phar install -o -d ./aerys \
&& php composer.phar install -o -d ./react-php \
&& chmod +x ./start_benchmark.sh \
&& rm -rf ./wrk \
&& rm -rf ./libuv \
&& rm -rf ./libevent \
&& rm composer.phar