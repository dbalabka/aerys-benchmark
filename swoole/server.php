<?php
/*
 * (c) 2018, Dmitrijs Balabka
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

use Swoole\Http\{Server, Request, Response};

$server = new Server('0.0.0.0', 8080);

$server->on('request', function(Request $request, Response $response) {
    if ($request->server['request_uri'] === '/') {
        $response->status(200);
        $data = 'Hello world!';
    } else {
        $response->status(400);
        $data = 'Not Found';
    }
    $response->header('Content-Type', 'text/plain; charset=utf-8');
    $response->header('Keep-Alive', 'timeout=10000');
    $response->end($data);
});

$server->start();
