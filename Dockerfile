FROM docker.io/laravelsail/php74-composer:latest

LABEL maintainer "Opensource BSSD  <opensource@bssd.vn>"

RUN apt-get update && apt-get upgrade -y
RUN docker-php-ext-install bcmath sockets
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo_mysql 

RUN usermod -u 1000 www-data
RUN mkdir /app 
RUN chown -R www-data:www-data /app

USER www-data
WORKDIR /app
CMD [ "tail", "-f", "/dev/null"]
