[![Build Status](https://travis-ci.org/torinaki/aerys-benchmark.svg?branch=master)](https://travis-ci.org/torinaki/aerys-benchmark)

About
=====

**NOTE! This report still not finalized and result numbers is topic for discussion** 

The main goal of this benchmark report is to investigate state of PHP native 
possibilities to provide non-blocking HTTP server implementation. 
This report is focused on already existing solution [Aerys](https://github.com/amphp/aerys).


This benchmark report is inspired by: https://github.com/squeaky-pl/japronto


### TL;DR

Overall Aerys server performance is good. It is close to NodeJS performance, 
but still slower. Aerys latency distribution not much higher standard deviation in comparision with NodeJS.
This benchmark did not show big difference between reactors. For some reason native PHP reactor 
has almost same performance as reactors based on ev, libevent or php-uv extensions.
It is hard to compare ReactPHP with other servers implementations, because it doesn't support keeping connections alive.
Comparing old version of Aerys and latest version of ReactPHP with non-keep-alive we can see that Aerys performing better.

*Latest update: 19.01.2017*

## Testing environment

### Hardware

<!--- TODO: use AWS --->

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

### PHP

Used following PHP stable [supported](http://php.net/supported-versions.php) versions `^7.1`, `^7.2`. 

During benchmark we use default PHP settings by providing option `-n` that guarantee only required modules are loaded. 

Native assertion framework is disabled with option:
```ini
zend.assertions=-1
```

OpCache might provide additional byte code optimizations. 
It is enabled for CLI with maximal optimization level:
```ini
opcache.enable=1
opcache.enable_cli=1
opcache.optimization_level=0xffffffff
opcache.file_update_protection=0
```

Also used development version of PHP with JIT support based on branch from Zend Github repository:
https://github.com/zendtech/php-src/tree/jit-dynasm/

For benchmarking used [default JIT settings](https://github.com/zendtech/php-src/blob/jit-dynasm/ext/opcache/jit/zend_jit.h#L24)
with following OPCache settings adjustments:
```ini
opcache.jit_buffer_size=32M
```

#### libuv

Library version: [v1.19.0](https://github.com/libuv/libuv)
Extension version: [0.2.2](https://pecl.php.net/package/uv)

#### libevent

Library version: [2.1.8](https://github.com/libevent/libevent)
Extension version: [2.3.0](https://pecl.php.net/package/event)

#### ev

Library version: [???](https://github.com/enki/libev)
Extension version: [1.0.4](https://pecl.php.net/package/ev)



### NodeJS

Latest stable version `^8.9`

By default NodeJS keeping connections alive without limiting timeout and connections amount:
```text
Connection: keep-alive
```

Server response with keep alive (159 byte)
```text
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
Content-Length: 12
X-Powered-By: Node Server
Date: Sat, 20 Jan 2018 10:48:03 GMT
Connection: keep-alive
```

<!--- TODO: mention about NodeJS JIT warmuping --->

### Aerys

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

Server response with keep alive (162 byte):
```text
HTTP/1.1 200 OK
content-type: text/plain; charset=utf-8
x-powered-by: AerysServer
content-length: 12
keep-alive: timeout=10000
date: Sat, 20 Jan 2018 10:45:51 GMT
```
w/o keep alive (154 byte):
```text
HTTP/1.1 200 OK
content-type: text/plain; charset=utf-8
x-powered-by: AerysServer
content-length: 12
connection: close
date: Sat, 20 Jan 2018 10:44:44 GMT
```

UvReactor, EvReactor, LibeventReactor, NativeReactor

### ReactPHP

At this moment ReactPHP does not support keeping alive connection: 
* https://github.com/reactphp/http/blob/master/README.md#response
* https://github.com/reactphp/http/issues/39

```text
Connection: close
```

Server response w/o keep alive (154 byte)
```text
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
X-Powered-By: React/alpha
Date: Sat, 20 Jan 2018 10:43:06 GMT
Content-Length: 13
Connection: close
```


### HTTP benchmarking tool

[wrk](https://github.com/torinaki/wrk/tree/lua-plot-report) version 4.0.2

Testing settings:
 * 1 thread
 * 100 connections
 * during 30 seconds
```bash
wrk -t1 -c100 -d30s --latency http://127.0.0.1:8080/
```

Build Docker images
=======================

To build Docker images just run: 
```bash
sh ./build.sh
```

Run benchmark
=============

To run benchmark you need installed Docker.
Following command will fetch [latest image](https://hub.docker.com/r/dmitrybalabka/aerys-benchmark/) from Docker hub with build-in all needed software and start benchmark:
```bash
docker run --ulimit nofile=30000:30000 dmitrybalabka/aerys-benchmark:${DOCKER_PHP_VERSION}
```
Replace `${DOCKER_PHP_VERSION}` with any [available image tag](https://hub.docker.com/r/dmitrybalabka/aerys-benchmark/tags/) (php71, php72, php72jit)

## Run local copy of benchmark in docker

```bash
git clone git@github.com:torinaki/aerys-benchmark.git
cd aerys-benchmark
sh ./build/install-local.sh
docker run -v "`pwd`:/app" dmitrybalabka/aerys-benchmark:php71
```


Benchmark result
================

| Server            | Settings                            | 50%           | 75%   | 90% | 99% |
| -------------     | ---------------                     |:-------------:| -----:| ---:|---: |
| ReactPHP          | w/o keep-alive                      |               |       |     |     |
| ReactPHP          | w/o keep-alive + OPCache            |               |       |     |     |
| ReactPHP          | w/o keep-alive + OPCache + JIT      |               |       |     |     |
| Aerys + Amp1      | w/o keep-alive                      |               |       |     |     |
| Aerys + Amp1      | w/o keep-alive + OPCache            |               |       |     |     |
| Aerys + Amp1      | w/o keep-alive + OPCache + JIT      |               |       |     |     |
| Aerys + Amp1      | keep-alive + OPCache + JIT          |               |       |     |     |
| Aerys + Amp2      | keep-alive + OPCache + JIT          |               |       |     |     |
| Aerys + Amp2 tiny | keep-alive + OPCache + JIT          |               |       |     |     |
| Aerys + Amp2      | keep-alive + OPCache                |               |       |     |     |
| Aerys + Amp2      | keep-alive + OPCache + JIT + ev     |               |       |     |     |
| Aerys + Amp2      | keep-alive + OPCache + JIT + event  |               |       |     |     |
| Aerys + Amp2      | keep-alive + OPCache + JIT + uv     |               |       |     |     |
| NodeJS            | keep-alive + w/o timeout            |               |       |     |     |

