<?php
declare(strict_types=1);
/*
 * (c) 2018, Dmitrijs Balabka
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

require __DIR__ . '/vendor/autoload.php';

// This is a very simple HTTP server that just prints a message to each client that connects.
// It doesn't check whether the client sent an HTTP request.

// You might notice that your browser opens several connections instead of just one, even when only making one request.

use Amp\Loop;
use Amp\Socket\ResourceSocket;
use Amp\Socket\Server;
use function Amp\asyncCoroutine;

Loop::run(function () {
    $requestCount  = 0;
    $clientHandler = asyncCoroutine(function (ResourceSocket $socket) use (&$requestCount) {
        $address = $socket->getRemoteAddress();
        $ip = $address->getHost();
        $port = $address->getPort();

        $buffer = '';
        while (($chunk = yield $socket->read()) !== null) {
            $buffer .= $chunk;
            if (\substr($buffer, -4, 4) === "\r\n\r\n") {
                $date       = \gmdate('D, d M Y H:i:s', \time()) . " GMT";
                $body       = 'Hello world!';
                $bodyLength = \strlen($body);
                $requestCount++;
                echo $requestCount;
                yield $socket->write("HTTP/1.1 200 OK\r\nContent-Type: text/plain; Charset=utf-8\r\nX-Powered-By: AerysServer\r\nConnection: keep-alive\r\nContent-Length: ${bodyLength}\r\nKeep-Alive: timeout=10000\r\nDate: ${date}\r\n\r\n${body}\r\n\r\n\r\n\r\n");
            }
        }
    });

    $server = Server::listen('0.0.0.0:8080');

    echo 'Listening for new connections on ' . $server->getAddress() . " ..." . PHP_EOL;

    while ($socket = yield $server->accept()) {
        $clientHandler($socket);
        if ($requestCount > 4) {
            exit;
        }
    }
});
