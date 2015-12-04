FROM php:5.4.41-apache

MAINTAINER Yuichi Saotome <y@sotm.jp>

ENV ECCUBE_PATH /var/www/ec-cube

ENV ECCUBE_BRANCHE master

RUN apt-get update && apt-get install --no-install-recommends -y \
        git vim curl wget sudo libfreetype6-dev libjpeg62-turbo-dev libmcrypt-dev libmcrypt-dev libxml2-dev libpq-dev libpq5 postgresql-client \
        && docker-php-ext-configure \
        gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
        && docker-php-ext-install \
        mbstring zip gd xml pdo pdo_pgsql pdo_mysql soap \
        && rm -r /var/lib/apt/lists/*

RUN ls -lt ${PHP_INI_DIR}/conf.d/
COPY config/php.ini ${PHP_INI_DIR}/

## Clone EC-CUBE3
RUN git clone -b ${ECCUBE_BRANCHE} https://github.com/EC-CUBE/ec-cube.git ${ECCUBE_PATH}

## Edit Configs
RUN chown -R www-data:www-data ${ECCUBE_PATH}
RUN sed -i -e "s|/var/www/html|${ECCUBE_PATH}/html|g" /etc/apache2/apache2.conf

WORKDIR ${ECCUBE_PATH}
RUN curl -sS https://getcomposer.org/installer | php
RUN php composer.phar install --dev --no-interaction

EXPOSE 80

RUN a2enmod rewrite
CMD apache2-foreground

