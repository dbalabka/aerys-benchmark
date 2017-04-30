<?php
/*
 * (c) 2017, Dmitrijs Balabka
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

const AERYS_OPTIONS = [
    // help avoid connection errors during benchmark
    'connectionsPerIP' => 100,
    'disableKeepAlive' => true,
    'maxKeepAliveRequests' => 1,
    'keepAliveTimeout' => 1,
];

(new \Aerys\Host)
    ->name("localhost")
    ->expose("0.0.0.0", 8080)
    ->use(function(Aerys\Request $req, Aerys\Response $resp) {
        if ($req->getUri() === '/') {
            $data = 'Hello world!';
            $status = 200;
        } else {
            $data = 'Not Found';
            $status = 400;
        }
        $resp->addHeader('Content-Type', 'text/plain; charset=utf-8');
        $resp->addHeader('X-Powered-By', 'AerysServer');
        $resp->setStatus($status);
        $resp->end($data);
    });