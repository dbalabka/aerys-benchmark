#
# Latest PHP 7.0.*
#

FROM php:7.0-cli
# Set the working directory to /app
WORKDIR /app
# Copy the current directory contents into the container at /app
ADD . /app
# Compile and install required PHP ext.
RUN bash build/install.sh
# Run benchmark on startup
CMD ["bash", "start_benchmark.sh"]