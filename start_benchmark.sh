#!/usr/bin/env bash

PHP_COMMAND='php -n'
NODEJS_COMMAND='node'

AERYS_COMMAND="./aerys/vendor/bin/aerys -w 1 -c ./aerys/server.php --worker-args=\"-n\""
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
    eval "${2} &>/dev/null &"
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

printf "PHP version:\n"
eval "${PHP_COMMAND} -c ./php/default.ini -v"

start_benchmark "Benchmarking ReactPHP" "${PHP_COMMAND} -c ./php/default.ini ${REACTPHP_COMMAND}"

start_benchmark "Benchmarking Aerys" "${PHP_COMMAND} -c ./php/default.ini ${AERYS_COMMAND}"
start_benchmark "Benchmarking Aerys with ev" "${PHP_COMMAND} -c ./php/default-with-ev.ini ${AERYS_COMMAND}"
start_benchmark "Benchmarking Aerys with event" "${PHP_COMMAND} -c ./php/default-with-event.ini ${AERYS_COMMAND}"
start_benchmark "Benchmarking Aerys with uv" "${PHP_COMMAND} -c ./php/default-with-uv.ini ${AERYS_COMMAND}"

# Benchmarking NodeJS
printf "\nNodeJS version:\n"
eval "${NODEJS_COMMAND} -v"
start_benchmark "Benchmarking NodeJS" "${NODEJS_COMMAND} ${NODEJS_SERVER_COMMAND}"

printf "\n${INFO}CPU info:${END}\n"
cat /proc/cpuinfo 2>/dev/null | egrep "model name|processor|cores|flags|cache" \
 || sysctl -a | egrep "machdep.cpu.(brand_string|thread_count|core_count|features)"

printf "\n${INFO}Memory info:${END}\n"
cat /proc/meminfo 2>/dev/null | egrep "MemTotal|MemFree|SwapCached" \
 || sysctl hw.memsize

printf "\n${INFO}Linux info${END}:\n"
uname -a
lsb_release 2>/dev/null