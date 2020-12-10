FROM php:8.0.0-fpm-alpine3.12

# update && install nginx 
RUN apk update && apk add nginx && \
    mkdir -p /run/nginx && \
    # forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log 

# Get latest Composer and set composer bin into path
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN echo "export PATH=$PATH:~/.composer/vendor/bin \r" >> ~/.bashrc

# Install node and git
RUN apk add --no-cache nodejs npm git && \
    npm i -g yarn && \ 
    # its necessary to nova cards
    apk add --no-cache libpng-dev 

# INSTALL PHP EXTENCIONS
## Install Xdebug
RUN apk add --no-cache autoconf make g++ && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug  && \
    # dependences for extencions
    apk add --no-cache \
    # dependences for zip
    libzip-dev \
    # dependences for xml
    libxml2-dev \
    # dependences for intl
    icu-dev && \
    # CONFIGURE
    docker-php-ext-configure intl && \
    # INSTALL EXTENCIONS
    docker-php-ext-install zip \
    bcmath \
    mysqli \
    pdo_mysql \
    exif \
    intl && \
    # Remove builder depencences
    apk del --no-cache autoconf make g++

#CONFIGS
#copying cofings: xdebug nginx php-fpm
COPY xdebug.ini php-fpm.conf nginx.conf ./

# Feed configs
RUN mkdir -p /etc/nginx/conf.d/default/ && \
    mv php-fpm.conf /usr/local/etc/php-fpm.d/zz-docker.conf &&  \
    mv nginx.conf /etc/nginx/conf.d/default.conf && \
    cat xdebug.ini >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini  && \
    # remove from here
    rm -rf xdebug.ini php-fpm.conf nginx.conf

WORKDIR /www

EXPOSE 80

STOPSIGNAL SIGQUIT

ENTRYPOINT docker-php-entrypoint php-fpm -D -R && nginx -g "daemon off;"
