#
# Latest PHP 7.1.*
#

FROM php:7.1-cli
WORKDIR /app
ADD . /app
RUN bash build/install.sh
CMD ["bash", "start_benchmark.sh"]
