#
# PHP 7.2.* with JIT compilation support(Dynasm)
#

FROM mente/php-jit:latest
WORKDIR /app
ADD . /app
RUN bash build/install.sh
CMD ["bash", "start_benchmark.sh"]
