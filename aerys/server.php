<?php
/*
 * (c) 2017, Dmitrijs Balabka
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

const AERYS_OPTIONS = [
    'connectionsPerIP' => 100,
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
        $resp->addHeader('Content-Type', 'text/plain; encoding=utf-8');
        $resp->addHeader('Content-Length', strlen($data));
        $resp->setStatus($status);
        $resp->end($data);
    });