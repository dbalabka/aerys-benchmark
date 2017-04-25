<?php

use React\EventLoop\Factory;
use React\Socket\Server;
use React\Http\Request;
use React\Http\Response;

require __DIR__ . '/vendor/autoload.php';

$loop = Factory::create();
$socket = new Server('0.0.0.0:8080', $loop);

$server = new \React\Http\Server($socket);
$server->on('request', function (Request $request, Response $response) {
    if ($request->getPath() === '/') {
        $data = 'Hello world!';
        $status = 200;
    } else {
        $data = 'Not Found';
        $status = 400;
    }
    $response->writeHead(
        $status,
        [
            'Content-Type' => 'text/plain; encoding=utf-8',
            'Content-Length' => strlen($data),
        ]
    );
    $response->end($data . PHP_EOL);
});

echo 'Listening on http://' . $socket->getAddress() . PHP_EOL;

$loop->run();
