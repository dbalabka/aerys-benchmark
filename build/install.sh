#!/usr/bin/env bash

#
# Will install and compile required libraries
#

apt-get update \
&& apt-get install build-essential libssl-dev git libtool m4 automake psmisc gnupg libicu-dev zlib1g-dev -y \
&& curl -sL https://deb.nodesource.com/setup_8.x | bash - \
&& apt-get install nodejs -y \
&& git clone https://github.com/torinaki/wrk.git && cd wrk && git checkout lua-plot-report \
&& make && rm -f /usr/local/bin/wrk && cp wrk /usr/local/bin && cd .. \
&& git clone https://github.com/libuv/libuv.git && cd libuv && git checkout v1.11.0 \
&& sh autogen.sh && ./configure && make `#&& make check` \
&& make install && cd .. \
&& git clone https://github.com/libevent/libevent.git && cd libevent && git checkout release-2.1.8-stable \
&& sh autogen.sh && ./configure && make `#&& make verify` \
&& make install && cd .. \
&& docker-php-ext-configure pcntl \
&& docker-php-ext-install pcntl \
&& docker-php-ext-enable pcntl \
&& docker-php-ext-configure intl \
&& docker-php-ext-install intl \
&& docker-php-ext-enable intl \
&& docker-php-ext-install sockets \
&& docker-php-source extract \
&& pecl channel-update pecl.php.net \
&& printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n" | pecl install event-2.4.3 swoole-4.2.9 \
&& git clone https://github.com/bwoebi/php-uv.git && cd ./php-uv \
&& phpize && ./configure && make && make install && cd .. && rm -rf ./php-uv \
&& docker-php-source delete \
&& sh ./build/install-local.sh \
&& chmod +x ./start_benchmark.sh \
&& rm -rf ./wrk \
&& rm -rf ./libuv \
&& rm -rf ./libevent \
&& rm composer.phar
