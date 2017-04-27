#!/usr/bin/env bash

PHP_COMMAND='php -n'
NODEJS_COMMAND='node'

AERYS_COMMAND="./aerys/vendor/bin/aerys -w 1 -c ./aerys/server.php --worker-args=\"-n\""
REACTPHP_COMMAND="./react-php/server.php"
NODEJS_SERVER_COMMAND="./nodejs/server.js"

function start_benchmark {
    printf "\nStart server...\n${1}"
    eval "${1} &>/dev/null &" || exit
    SERVER_PID=$!

    sleep 1

    printf "\n\nRun benchmark...\n"
    ./bin/wrk -t1 -c100 -d30s --latency http://127.0.0.1:8080/

    printf "\n\nStoping server...\n"
    killall -9 php node
    sleep 2
}

printf "PHP version:\n"
eval "${PHP_COMMAND} -c ./php/default.ini -v"

start_benchmark "${PHP_COMMAND} -c ./php/default.ini ${REACTPHP_COMMAND}"

start_benchmark "${PHP_COMMAND} -c ./php/default.ini ${AERYS_COMMAND}"
start_benchmark "${PHP_COMMAND} -c ./php/default-with-ev.ini ${AERYS_COMMAND}"
start_benchmark "${PHP_COMMAND} -c ./php/default-with-event.ini ${AERYS_COMMAND}"
start_benchmark "${PHP_COMMAND} -c ./php/default-with-uv.ini ${AERYS_COMMAND}"

printf "\nNodeJS version:\n"
eval "${NODEJS_COMMAND} -v"
start_benchmark "${NODEJS_COMMAND} ${NODEJS_SERVER_COMMAND}"

