#!/usr/bin/env bash

PHP_COMMAND="php -n ${PHP_OPTIONS}"
NODEJS_COMMAND='node'

AERYS_COMMAND="./aerys/vendor/bin/aerys -w 1 -c ./aerys/server.php --worker-args=\"-n\""
AERYS_WO_KEEP_ALIVE_COMMAND="./aerys/vendor/bin/aerys -w 1 -c ./aerys/server-wo-keep-alive.php --worker-args=\"-n\""
REACTPHP_COMMAND="./react-php/server.php"
NODEJS_SERVER_COMMAND="./nodejs/server.js"

URL="http://127.0.0.1:8080/"

WARNING='\033[41m'
SUCCESS='\033[42m'
INFO='\033[33m'
END='\033[0m' # No Color

function start_benchmark {

    printf "\n${SUCCESS}${1}${END}"

    printf "\n\n${INFO}Start server...${END}\n${2}"
    eval "${2} 1>/dev/null &"
    SERVER_PID=$!

    sleep 1

    printf "\n\n${INFO}Response example:${END}\n"
    curl -I $URL || { printf "${WARNING}Failed to connect to server!${END}\n"; exit 1; }

    printf "${INFO}Run benchmark...${END}\n"
    ./bin/wrk -t1 -c100 -d30s --latency ${URL} || { printf "${WARNING}Failed to start benchmark!${END}\n"; exit 1; }

    printf "\n\n${INFO}Stoping server...${END}\n"
    killall -9 php node
    sleep 2
}
function checkPhpConfiguration {
    printf "\n${INFO}Check PHP configuration: ${END}"
    eval "${PHP_COMMAND} -c ./php/default.ini -i | grep 'zend.assertions => -1 => -1' 1>/dev/null" || { printf "${WARNING}Zend assertion isn't disabled!${END}\n"; exit 1; }
    eval "${PHP_COMMAND} -c ./php/default-opcache.ini -i | grep 'opcache.enable => On => On' 1>/dev/null" || { printf "${WARNING}OpCache isn't loaded!${END}\n"; exit 1; }
    eval "${PHP_COMMAND} -c ./php/default-opcache-ev.ini -i | grep  '^ev$' 1>/dev/null" || { printf "${WARNING}EV isn't loaded!${END}\n"; exit 1; }
    eval "${PHP_COMMAND} -c ./php/default-opcache-event.ini -i | grep  '^event$' 1>/dev/null" || { printf "${WARNING}Libevent isn't enabled!${END}\n"; exit 1; }
    eval "${PHP_COMMAND} -c ./php/default-opcache-uv.ini -i | grep  '^uv$' 1>/dev/null" || { printf "${WARNING}Libuv isn't enabled!${END}\n"; exit 1; }
    printf "OK\n"
}
printf "${INFO}PHP version:${END}\n"
eval "${PHP_COMMAND} -c ./php/default.ini -v"

checkPhpConfiguration

start_benchmark "Benchmarking ReactPHP (w/o keep-alive)" "${PHP_COMMAND} -c ./php/default.ini ${REACTPHP_COMMAND}"
start_benchmark "Benchmarking ReactPHP (w/o keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${REACTPHP_COMMAND}"

start_benchmark "Benchmarking Aerys (w/o keep-alive)" "${PHP_COMMAND} -c ./php/default.ini ${AERYS_WO_KEEP_ALIVE_COMMAND}"
start_benchmark "Benchmarking Aerys (w/o keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AERYS_WO_KEEP_ALIVE_COMMAND}"
start_benchmark "Benchmarking Aerys (keep-alive + OPCache)" "${PHP_COMMAND} -c ./php/default-opcache.ini ${AERYS_COMMAND}"
start_benchmark "Benchmarking Aerys (keep-alive + OPCache + ev)" "${PHP_COMMAND} -c ./php/default-opcache-ev.ini ${AERYS_COMMAND}"
start_benchmark "Benchmarking Aerys (keep-alive + OPCache + event)" "${PHP_COMMAND} -c ./php/default-opcache-event.ini ${AERYS_COMMAND}"
start_benchmark "Benchmarking Aerys (keep-alive + OPCache + uv)" "${PHP_COMMAND} -c ./php/default-opcache-uv.ini ${AERYS_COMMAND}"

# Benchmarking NodeJS
printf "\nNodeJS version:\n"
eval "${NODEJS_COMMAND} -v"
start_benchmark "Benchmarking NodeJS (keep-alive)" "${NODEJS_COMMAND} ${NODEJS_SERVER_COMMAND}"

printf "\n${INFO}CPU info:${END}\n"
cat /proc/cpuinfo 2>/dev/null | egrep "model name|processor|cores|flags|cache" \
 || sysctl -a | egrep "machdep.cpu.(brand_string|thread_count|core_count|features)"

printf "\n${INFO}Memory info:${END}\n"
cat /proc/meminfo 2>/dev/null | egrep "MemTotal|MemFree|SwapCached" \
 || sysctl hw.memsize

printf "\n${INFO}Linux info${END}:\n"
uname -a
lsb_release 2>/dev/null