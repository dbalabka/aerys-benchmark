About
=====

Inspired by: https://github.com/squeaky-pl/japronto 

## TL;DR

Overall Aerys server performance is good. It faster then ReactPHP and 
it is only x4 slower than NodeJS. Latency distribution in comparision with NodeJS has almost same values for
50%, 75%, 90% percentiles, but sometimes requests are very slow(perc. 99% = 226.93ms)
that spoils overall performance picture.
There no big difference between reactors. For some reason native PHP reactor 
has almost same performance as reactors based on ev, libevent or php-uv extensions.

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

## Testing tool
```bash
wrk -t1 -c100 -d30s --latency http://127.0.0.1:8080/
```

PHP
===


## ReactPHP

Start server:
```bash
cd ./react-php
php -dzend.assertions=-1 -dxdebug.default_enable=0 ./server.php
```

Result:
```text
Running 30s test @ http://127.0.0.1:51790/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    20.26ms    4.62ms  71.84ms   92.09%
    Req/Sec     1.60k   329.64     2.07k    91.00%
  Latency Distribution
     50%   19.54ms
     75%   20.56ms
     90%   23.10ms
     99%   40.57ms
  16021 requests in 30.07s, 2.70MB read
  Socket errors: connect 0, read 810, write 55, timeout 0
Requests/sec:    532.72
Transfer/sec:     92.08KB
```

## Aerys

### NativeReactor

Start server:
```bash
cd ./aerys
php -dzend.assertions=-1 -dxdebug.default_enable=0 ./vendor/bin/aerys -c ./server.php
```

Result:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    16.08ms   62.31ms 902.34ms   98.10%
    Req/Sec     3.62k   425.59     4.03k    89.33%
  Latency Distribution
     50%    7.85ms
     75%    8.25ms
     90%    9.47ms
     99%  383.05ms
  108038 requests in 30.01s, 18.23MB read
  Socket errors: connect 0, read 3527, write 0, timeout 0
Requests/sec:   3600.30
Transfer/sec:    621.96KB
```

### LibeventReactor

Start server:
```bash
cd ./aerys
php -dzend.assertions=-1 -dxdebug.default_enable=0 -dextension="/usr/local/opt/php70-event/event.so" ./vendor/bin/aerys -c ./server.php
```

Result:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    12.66ms   40.60ms 569.08ms   98.44%
    Req/Sec     3.69k   425.23     3.99k    90.00%
  Latency Distribution
     50%    7.73ms
     75%    8.08ms
     90%    9.02ms
     99%  219.16ms
  110333 requests in 30.03s, 18.61MB read
  Socket errors: connect 0, read 3599, write 0, timeout 0
Requests/sec:   3674.70
Transfer/sec:    634.82KB
```

### EvReactor

Start server:
```bash
cd ./aerys
php -dzend.assertions=-1 -dxdebug.default_enable=0 -dextension="/usr/local/opt/php70-ev/ev.so" ./vendor/bin/aerys -c ./server.php
```

Result:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    12.54ms   40.92ms 591.49ms   98.50%
    Req/Sec     3.75k   232.77     3.96k    90.67%
  Latency Distribution
     50%    7.80ms
     75%    8.02ms
     90%    8.72ms
     99%  221.44ms
  111999 requests in 30.00s, 18.90MB read
  Socket errors: connect 0, read 3658, write 0, timeout 0
Requests/sec:   3732.72
Transfer/sec:    644.85KB
```

### UvReactor

Start server:
```bash
cd ./aerys
php -dzend.assertions=-1 -dxdebug.default_enable=0 -dextension="/usr/local/opt/php70-uv/uv.so" ./vendor/bin/aerys -c ./server.php
```

Result:
```text
Running 30s test @ http://127.0.0.1:8080/
  1 threads and 100 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency    12.58ms   41.11ms 585.23ms   98.49%
    Req/Sec     3.75k   239.80     3.98k    88.33%
  Latency Distribution
     50%    7.77ms
     75%    8.09ms
     90%    8.80ms
     99%  226.93ms
  112018 requests in 30.01s, 18.90MB read
  Socket errors: connect 0, read 3669, write 0, timeout 0
Requests/sec:   3733.04
Transfer/sec:    644.91KB
```

NodeJS
======

```bash
cd ./nodejs
node ./server.js
wrk -t1 -c100 -d30s --latency http://127.0.0.1:8080/
```

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