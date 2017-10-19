[![Build Status](https://travis-ci.org/torinaki/aerys-benchmark.svg?branch=docker-phpjit-integration)](https://travis-ci.org/torinaki/aerys-benchmark)

About
=====

**NOTE! This report still not finalized and result numbers is topic for discussion** 

The main goal of this benchmark report is to investigate state of PHP native 
possibilities to provide non-blocking HTTP server implementation. 
This report is focused on already existing solution [Aerys](https://github.com/amphp/aerys).


This benchmark report is inspired by: https://github.com/squeaky-pl/japronto


## TL;DR

Overall Aerys server performance is good. It is close to NodeJS performance, 
but still slower by ~23%. 
Aerys latency distribution has much higher standard deviation in comparision with NodeJS.
There no big difference between reactors. For some reason native PHP reactor 
has almost same performance as reactors based on ev, libevent or php-uv extensions.
It is hard to compare ReactPHP with other servers implementations, 
because it doesn't support keeping connections alive.
But comparing Aerys and ReactPHP non-keep-alive versions we can see that ReactPHP performing better.

## Testing environment

TODO: use AWS

```text
Hardware:

    Hardware Overview:

      Model Name: MacBook Pro
      Model Identifier: MacBookPro9,2
      Processor Name: Intel Core i7
      Processor Speed: 2,9 GHz
      Number of Processors: 1
      Total Number of Cores: 2
      L2 Cache (per Core): 256 KB
      L3 Cache: 4 MB
      Memory: 8 GB
```

```text
php -n --version
PHP 7.0.18 (cli) (built: Apr 25 2017 02:53:38) ( NTS )
Copyright (c) 1997-2017 The PHP Group
Zend Engine v3.0.0, Copyright (c) 1998-2017 Zend Technologies
```

## Testing tool

[wrk](https://github.com/wg/wrk) version 4.0.2

Testing settings:
 * 1 thread
 * 100 connections
 * during 30 seconds
```bash
wrk -t1 -c100 -d30s --latency http://127.0.0.1:8080/
```

Comparison table
================

| Server (settings)                     | 50%           | 75%   | 90% | 99% |
| -------------                         |:-------------:| -----:| ---:|---: |
| ReactPHP (w/o keep-alive)             |               |       |     |     |
| ReactPHP (w/o keep-alive + OPCache)   |               |       |     |     |
| Aerys (w/o keep-alive)                |               |       |     |     |
| Aerys (w/o keep-alive + OPCache)      |               |       |     |     |
| Aerys (keep-alive + OPCache)          |               |       |     |     |
| Aerys (keep-alive + OPCache + ev)     |               |       |     |     |
| Aerys (keep-alive + OPCache + event)  |               |       |     |     |
| Aerys (keep-alive + OPCache + uv)     |               |       |     |     |
| NodeJS (keep-alive)                   |               |       |     |     |
 
PHP
===

We use default PHP settings:   
```text
  -n               No configuration (ini) files will be used
```
with disabled native assertion framework:
```text
-dzend.assertions=-1
```


## ReactPHP

At this moment ReactPHP does not support keeping alive connection: 
* https://github.com/reactphp/http/blob/master/README.md#response
* https://github.com/reactphp/http/issues/39

```text
Connection: close
```

### Benchmark
Start server:
```bash
cd ./react-php
php -n -dzend.assertions=-1 ./server.php
```

Result:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     8.63ms    6.76ms 112.12ms   98.32%
    Req/Sec     3.52k     1.46k    4.52k    84.78%
  Latency Distribution
     50%    7.86ms
     75%    8.08ms
     90%    9.51ms
     99%   21.15ms
  16123 requests in 30.04s, 2.72MB read
  Socket errors: connect 0, read 310, write 116, timeout 0
Requests/sec:    536.79
Transfer/sec:     92.78KB
```

## Aerys

To avoid connections rejections Aerys must be configured with higher amount of simultaneous
connections per one IP address:
```php
const AERYS_OPTIONS = [
    'connectionsPerIP' => 100,
];
```

By default Aerys keeping connections alive with following settings: 
```text
keep-alive: timeout=6, max=999
```

### Benchmark with NativeReactor

Start server with one worker only:
```bash
cd ./aerys
php -n -dzend.assertions=-1 ./vendor/bin/aerys -w 1 -c ./server.php --worker-args="-n"
```

Results:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    10.90ms   18.47ms 425.74ms   98.90%
    Req/Sec    10.71k     1.02k   12.09k    87.67%
  Latency Distribution
     50%    8.94ms
     75%    9.19ms
     90%   10.69ms
     99%   39.13ms
  319800 requests in 30.00s, 53.95MB read
Requests/sec:  10658.39
Transfer/sec:      1.80MB
```

Result with installed xdebug, but disabled in command line. 
As you can see it significantly slows down the server. During benchmark testing
zend_extension configuration line must be commented out.
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    12.67ms   41.88ms 610.45ms   98.48%
    Req/Sec     3.76k   245.95     4.04k    89.00%
  Latency Distribution
     50%    7.78ms
     75%    8.05ms
     90%    8.71ms
     99%  230.37ms
  112109 requests in 30.01s, 18.91MB read
  Socket errors: connect 0, read 3661, write 0, timeout 0
Requests/sec:   3736.22
Transfer/sec:    645.46KB
```

Start server without keeping connection alive:
```bash
cd ./aerys
php -n -dzend.assertions=-1 ./vendor/bin/aerys -w 1 -c ./server-wo-keep-alive.php --worker-args="-n"
```

As you can see server performance significantly decreases. 
Comparing with ReactPHP latency distribution is worse,
but overall performance is same. 
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    35.98ms   68.99ms 705.30ms   96.94%
    Req/Sec     3.41k     1.15k    5.30k    72.34%
  Latency Distribution
     50%   22.38ms
     75%   24.32ms
     90%   49.09ms
     99%  509.17ms
  16249 requests in 30.03s, 2.54MB read
Requests/sec:    541.04
Transfer/sec:     86.65KB

```

### Benchmark with LibeventReactor

Start server:
```bash
cd ./aerys
php -n -dzend.assertions=-1 -dextension="/usr/local/opt/php70-event/event.so" ./vendor/bin/aerys -w 1 -c ./server.php  --worker-args="-n"
```

Results:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    11.17ms   18.96ms 485.22ms   98.84%
    Req/Sec    10.50k     1.01k   11.42k    87.33%
  Latency Distribution
     50%    9.07ms
     75%    9.52ms
     90%   10.93ms
     99%   48.21ms
  313558 requests in 30.01s, 52.89MB read
Requests/sec:  10449.34
Transfer/sec:      1.76MB
```

### Benchmark with EvReactor

Start server:
```bash
cd ./aerys
php -n -dzend.assertions=-1 -dextension="/usr/local/opt/php70-ev/ev.so" ./vendor/bin/aerys -w 1 -c ./server.php  --worker-args="-n"
```

Results:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    10.85ms   18.15ms 445.32ms   98.88%
    Req/Sec    10.77k   704.05    12.18k    90.33%
  Latency Distribution
     50%    9.04ms
     75%    9.29ms
     90%    9.92ms
     99%   41.32ms
  321362 requests in 30.00s, 54.21MB read
Requests/sec:  10710.55
Transfer/sec:      1.81MB
```

### Benchmark with UvReactor

Start server:
```bash
cd ./aerys
php -n -dzend.assertions=-1 -dextension="/usr/local/opt/php70-uv/uv.so" ./vendor/bin/aerys -w 1 -c ./server.php  --worker-args="-n"
```

Results:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    11.12ms   18.83ms 456.16ms   98.85%
    Req/Sec    10.55k     0.95k   11.85k    87.33%
  Latency Distribution
     50%    9.09ms
     75%    9.50ms
     90%   10.67ms
     99%   46.84ms
  314828 requests in 30.00s, 53.11MB read
Requests/sec:  10493.07
Transfer/sec:      1.77MB
```

NodeJS
======

By default NodeJS keeping connections alive without limiting timeout and connections amount:
```text
Connection: keep-alive
```

### Benchmark with keep alive

Start server:
```bash
cd ./nodejs
node ./server.js
wrk -t1 -c100 -d30s --latency http://127.0.0.1:8080/
```
Results:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency     7.23ms    1.26ms  56.01ms   95.84%
    Req/Sec    13.95k     1.02k   16.50k    87.67%
  Latency Distribution
     50%    6.99ms
     75%    7.44ms
     90%    7.87ms
     99%    9.63ms
  416258 requests in 30.00s, 46.45MB read
Requests/sec:  13873.65
Transfer/sec:      1.55MB
```

Build and run benchmark
=======================

To build Docker images just run: 
```bash
sh ./build.sh
```

To run benchmark:
```bash
docker run aerys-benchmark:php70
docker run aerys-benchmark:php71
docker run aerys-benchmark:php72jit
```