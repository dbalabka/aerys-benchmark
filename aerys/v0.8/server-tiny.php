<?php

use Amp\Http\Server\RequestHandler\CallableRequestHandler;
use Amp\Http\Server\Server;
use Amp\Http\Server\Request;
use Amp\Http\Server\Response;
use Amp\Http\Status;
use Amp\Loop;
use Amp\Socket;
use Psr\Log\NullLogger;
use Amp\Http\Server\Options;

require_once __DIR__ . '/vendor/autoload.php';

$options = (new Options())
    // help avoid connection errors during benchmark
    ->withConnectionsPerIpLimit(100)
    // to emulate NodeJS behavior
    ->withConnectionTimeout(10000)
    ->withoutCompression()
    ->withoutHttp2Upgrade()
    // TODO: options do not support this param?
//    ->withMaxRequestsPerConnection(PHP_INT_MAX)
;

$sockets = [
    Socket\listen("0.0.0.0:8080"),
];
$server = new Server(
    $sockets,
    new CallableRequestHandler(function (Request $request) {
        if ($request->getUri()) {
            $data = 'Hello world!';
            $status = Status::OK;
        } else {
            $data = 'Not Found';
            $status = Status::NOT_FOUND;
        }
        return new Response(
            $status,
            [
                'Content-Type' => 'text/plain; charset=utf-8',
                'X-Powered-By' => 'AerysServer',
            ],
            $data
        );
    }),
    new NullLogger(),
    $options
);

Loop::run(function () use ($server) {
    yield $server->start();

    // Stop the server gracefully when SIGINT is received.
    // This is technically optional, but it is best to call Server::stop().
    Loop::onSignal(\SIGINT, function (string $watcherId) use ($server) {
        Loop::cancel($watcherId);
        yield $server->stop();
    });
});
