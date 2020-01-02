#!/usr/bin/env bash

# Exit on any error
set -e

PHP_COMMAND="php -n"
NODEJS_COMMAND='node'

# Amp HTTP server
AERYS_COMMAND="./aerys/version/vendor/bin/aerys -w 1 -c ./aerys/version/server.php --worker-args=\"-n\""
AERYS_WO_KEEP_ALIVE_COMMAND="./aerys/version/vendor/bin/aerys -w 1 -c ./aerys/version/server-wo-keep-alive.php --worker-args=\"-n\""
AMP_HTTP_SERVER_TINY_COMMAND="./aerys/version/server-tiny.php"
AMP_HTTP_SERVER_SUPER_TINY_COMMAND="./aerys/version/server-super-tiny.php"
AERYS_CURRENT_VERSION="v2.x"

SWOOLE_COMMAND="./swoole/server.php"

# ReactPHP server script
REACTPHP_COMMAND="./react-php/server.php"

# NodeJS server script
NODEJS_SERVER_COMMAND="./nodejs/server.js"

PORT=8080
URL="http://localhost:${PORT}/"

WARNING='\033[41m'
SUCCESS='\033[42m'
INFO='\033[33m'
END='\033[0m' # No Color

function start_benchmark {

    printf "\n${SUCCESS}${1}${END}"

    printf "\n\n${INFO}Start server...${END}\n${2}"
    eval "${2} 1>/dev/null &"
    SERVER_PID=$!

    sleep 5
    lsof -i ":${PORT}"

    printf "\n\n${INFO}Response example:${END}\n"
    curl -I $URL || { printf "${WARNING}Failed to connect to server!${END}\n"; exit 1; }

    printf "${INFO}Run benchmark...${END}\n"
    wrk -t1 -c100 -d30s --latency ${URL} || { printf "${WARNING}Failed to start benchmark!${END}\n"; exit 1; }

    printf "\n\n${INFO}Stoping server...${END}\n"
    killall -9 php node || echo ""
    sleep 2
    lsof -i ":${PORT}"
}

function checkPhpConfiguration {
    printf "\n${INFO}Check PHP configuration: ${END}"
    eval "${PHP_COMMAND} -c ./php/default.ini -i | grep 'zend.assertions => -1 => -1' 1>/dev/null" || { printf "${WARNING}Zend assertion isn't disabled!${END}\n"; exit 1; }
    eval "${PHP_COMMAND} -c ./php/default-opcache.ini -i | grep 'opcache.enable => On => On' 1>/dev/null" || { printf "${WARNING}OpCache isn't loaded!${END}\n"; exit 1; }
    if php -v | egrep -q "^PHP 7.(1|2|3)"; then
        eval "${PHP_COMMAND} -c ./php/default-opcache-ev.ini -i | grep  '^ev$' 1>/dev/null" || { printf "${WARNING}EV isn't loaded!${END}\n"; exit 1; }
        eval "${PHP_COMMAND} -c ./php/default-opcache-event.ini -i | grep  '^event$' 1>/dev/null" || { printf "${WARNING}Libevent isn't enabled!${END}\n"; exit 1; }
    else
        echo "Skip Ev and Event check for current version of PHP"
    fi
    eval "${PHP_COMMAND} -c ./php/default-opcache-uv.ini -i | grep  '^uv$' 1>/dev/null" || { printf "${WARNING}Libuv isn't enabled!${END}\n"; exit 1; }
    printf "OK\n"
}

printf "${INFO}PHP version:${END}\n"
eval "${PHP_COMMAND} -c ./php/default.ini -v"

checkPhpConfiguration

start_benchmark "Benchmarking ReactPHP (w/o keep-alive)" "${PHP_COMMAND} -c ./php/default.ini ${REACTPHP_COMMAND}"
start_benchmark "Benchmarking ReactPHP (w/o keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${REACTPHP_COMMAND}"
php -n -c ./php/default-opcache.ini -i | grep "opcache.jit" 1>/dev/null \
&& start_benchmark "Benchmarking ReactPHP (w/o keep-alive + OPCache + w/o JIT)" "${PHP_COMMAND} -c ./php/default-opcache-nojit.ini ${REACTPHP_COMMAND}"

start_benchmark "Benchmarking Amp Server v0.5.0 (w/o keep-alive)" "${PHP_COMMAND} -c ./php/default.ini ${AERYS_WO_KEEP_ALIVE_COMMAND//version/v0.5.0}"
start_benchmark "Benchmarking Amp Server v0.5.0 (w/o keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AERYS_WO_KEEP_ALIVE_COMMAND//version/v0.5.0}"
php -n -c ./php/default-opcache.ini -i | grep "opcache.jit" 1>/dev/null \
&& start_benchmark "Benchmarking Amp Server v0.5.0 (w/o keep-alive + OPCache + w/o JIT)" "${PHP_COMMAND} -c ./php/default-opcache-nojit.ini ${AERYS_WO_KEEP_ALIVE_COMMAND//version/v0.5.0}"
start_benchmark "Benchmarking Amp Server v0.5.0 (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AERYS_COMMAND//version/v0.5.0}"

start_benchmark "Benchmarking Amp Server v0.7.4 (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AERYS_COMMAND//version/v0.7.4}"
start_benchmark "Benchmarking Amp Server v0.7.4 tiny (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/v0.7.4}"
php -n -c ./php/default-opcache.ini -i | grep "opcache.jit" 1>/dev/null \
&& start_benchmark "Benchmarking Amp Server v0.7.4 (keep-alive + OPCache + w/o JIT)" "${PHP_COMMAND} -c ./php/default-opcache-nojit.ini ${AERYS_COMMAND//version/v0.7.4}"

start_benchmark "Benchmarking Amp Server v0.8 tiny (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/v0.8}"
start_benchmark "Benchmarking Amp Server v0.8 super tiny (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AMP_HTTP_SERVER_SUPER_TINY_COMMAND//version/v0.8}"
php -n -c ./php/default-opcache.ini -i | grep "opcache.jit" 1>/dev/null \
&& start_benchmark "Benchmarking Amp Server v0.8 tiny (keep-alive + OPCache + w/o JIT)" "${PHP_COMMAND} -c ./php/default-opcache-nojit.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/v0.8}"

start_benchmark "Benchmarking Amp Server v1.x tiny (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/v1.x}"
start_benchmark "Benchmarking Amp Server v1.x super tiny (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AMP_HTTP_SERVER_SUPER_TINY_COMMAND//version/v1.x}"
php -n -c ./php/default-opcache.ini -i | grep "opcache.jit" 1>/dev/null \
&& start_benchmark "Benchmarking Amp Server v1.x tiny (keep-alive + OPCache + w/o JIT)" "${PHP_COMMAND} -c ./php/default-opcache-nojit.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/v1.x}"

start_benchmark "Benchmarking Amp Server ${AERYS_CURRENT_VERSION} tiny (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/${AERYS_CURRENT_VERSION}}"
start_benchmark "Benchmarking Amp Server ${AERYS_CURRENT_VERSION} super tiny (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AMP_HTTP_SERVER_SUPER_TINY_COMMAND//version/${AERYS_CURRENT_VERSION}}"
php -n -c ./php/default-opcache.ini -i | grep "opcache.jit" 1>/dev/null \
&& start_benchmark "Benchmarking Amp Server ${AERYS_CURRENT_VERSION} tiny (keep-alive + OPCache + w/o JIT)" "${PHP_COMMAND} -c ./php/default-opcache-nojit.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/${AERYS_CURRENT_VERSION}}"
# TODO: Amp Server doesn't work with EV extension on PHP 7.3
if php -v | egrep -q "^PHP 7.(1|2|3)"; then
    start_benchmark "Benchmarking Amp Server ${AERYS_CURRENT_VERSION} tiny (keep-alive + OPCache + ev)" "${PHP_COMMAND} -c ./php/default-opcache-ev.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/${AERYS_CURRENT_VERSION}}"
    start_benchmark "Benchmarking Amp Server ${AERYS_CURRENT_VERSION} tiny (keep-alive + OPCache + event)" "${PHP_COMMAND} -c ./php/default-opcache-event.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/${AERYS_CURRENT_VERSION}}"
else
    echo "Skip Ev and Event benchmark for current version of PHP"
fi
start_benchmark "Benchmarking Amp Server ${AERYS_CURRENT_VERSION} tiny (keep-alive + OPCache + uv)" "${PHP_COMMAND} -c ./php/default-opcache-uv.ini ${AMP_HTTP_SERVER_TINY_COMMAND//version/${AERYS_CURRENT_VERSION}}"

# Benchmark swoole
start_benchmark "Benchmarking Swoole (keep-alive + OPCache + swoole)" "${PHP_COMMAND} -c ./php/default-opcache-swoole.ini ${SWOOLE_COMMAND}"

# Benchmarking NodeJS
printf "\nNodeJS version:\n"
eval "${NODEJS_COMMAND} -v"
start_benchmark "Benchmarking NodeJS (keep-alive + w/o timeout)" "${NODEJS_COMMAND} ${NODEJS_SERVER_COMMAND}"

printf "\n${INFO}CPU info:${END}\n"
cat /proc/cpuinfo 2>/dev/null | egrep "model name|processor|cores|flags|cache" \
 || sysctl -a | egrep "machdep.cpu.(brand_string|thread_count|core_count|features)"

printf "\n${INFO}Memory info:${END}\n"
cat /proc/meminfo 2>/dev/null | egrep "MemTotal|MemFree|SwapCached" \
 || sysctl hw.memsize

printf "\n${INFO}Linux info${END}:\n"
uname -a
lsb_release 2>/dev/null
