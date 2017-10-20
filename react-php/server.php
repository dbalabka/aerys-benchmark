<?php

use React\EventLoop\Factory;
use React\Socket\Server as ServerSocket;
use React\Http\Response;
use React\Http\Server;
use Psr\Http\Message\ServerRequestInterface;

require __DIR__ . '/vendor/autoload.php';

$loop = Factory::create();
$socket = new ServerSocket('0.0.0.0:8080', $loop);

$server = new Server(function (ServerRequestInterface $request) {
    if ($request->getUri()->getPath() === '/') {
        $data = 'Hello world!';
        $status = 200;
    } else {
        $data = 'Not Found';
        $status = 400;
    }
    return new Response(
        $status,
        [
            'Content-Type' => 'text/plain; charset=utf-8',
            'Content-Length' => strlen($data),
        ],
        $data . PHP_EOL
    );
});
$server->listen($socket);

echo 'Listening on http://' . $socket->getAddress() . PHP_EOL;

$loop->run();
