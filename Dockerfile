
FROM composer:latest as untar
ARG FRAMADATE_VERSION=1.1.16
RUN apk add --no-cache wget
RUN wget -O framadata.tar.bz2 "https://framagit.org/framasoft/framadate/framadate/-/archive/${FRAMADATE_VERSION}/framadate-${FRAMADATE_VERSION}.tar.bz2" && \
    tar xjf framadata.tar.bz2 && \
    cd "framadate-${FRAMADATE_VERSION}" && \
    composer install && \
    cd ..

FROM php:apache
ARG FRAMADATE_VERSION=1.1.16
COPY --from=untar "/app/framadate-${FRAMADATE_VERSION}" /var/www/html

RUN apt-get update && \
    apt-get install -y libonig-dev libicu-dev libxml2-dev && \
    rm -rf /var/lib/apt/lists/* && \
    \
    docker-php-ext-install mbstring && \
    docker-php-ext-install intl && \
    docker-php-ext-install xml && \
    docker-php-ext-install pdo_mysql && \
    chmod 777 /var/www/html/app/inc && \
    chmod 777 /var/www/html/tpl_c
    
# Adding .htaccess rules
RUN cp /var/www/html/htaccess.txt /var/www/html/.htaccess && \
    a2enmod rewrite
