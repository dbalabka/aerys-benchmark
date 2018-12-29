<?php
/*
 * (c) 2018, Dmitrijs Balabka
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

use Swoole\Http\{Server, Request, Response};

$server = new Server('0.0.0.0', 8080);
// API docs: https://rawgit.com/tchiotludo/swoole-ide-helper/english/docs/classes/swoole_server.html#method_set
$server->set(array(
    # https://github.com/swoole/swoole-docs/blob/master/modules/swoole-server/configuration/worker_num.md
    'worker_num' => 1,
    # https://github.com/swoole/swoole-docs/blob/master/modules/swoole-server/configuration/reactor_num.md
    'reactor_num' => 1,
));
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
