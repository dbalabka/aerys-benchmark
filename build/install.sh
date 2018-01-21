#!/usr/bin/env bash

#
# Will install and compile required libraries
#

apt-get update \
&& apt-get install build-essential libssl-dev git libtool m4 automake psmisc gnupg -y \
&& curl -sL https://deb.nodesource.com/setup_8.x | bash - \
&& apt-get install nodejs -y \
&& git clone https://github.com/torinaki/wrk.git && cd wrk && git checkout lua-plot-report \
&& make \
&& cd ../bin && rm -f wrk && cp ../wrk/wrk wrk && cd .. \
&& git clone https://github.com/libuv/libuv.git && cd libuv && git checkout v1.19.1 \
&& sh autogen.sh && ./configure && make `#&& make check` \
&& make install && cd .. \
&& git clone https://github.com/libevent/libevent.git && cd libevent && git checkout release-2.1.8-stable \
&& sh autogen.sh && ./configure && make `#&& make verify` \
&& make install && cd .. \
&& docker-php-ext-install sockets \
&& docker-php-source extract \
&& pecl channel-update pecl.php.net \
&& printf "\n\n\n\n\n\n\n" | pecl install ev-1.0.4 event-2.3.0 \
&& git clone https://github.com/bwoebi/php-uv.git && cd ./php-uv \
&& phpize && ./configure && make && make install \
&& docker-php-source delete \
&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
&& php composer-setup.php \
&& php -r "unlink('composer-setup.php');" \
&& php composer.phar install -o -d ./aerys \
&& php composer.phar install -o -d ./aerys2 \
&& php composer.phar install -o -d ./react-php \
&& chmod +x ./start_benchmark.sh \
&& rm -rf ./wrk \
&& rm -rf ./libuv \
&& rm -rf ./libevent \
&& rm composer.phar
