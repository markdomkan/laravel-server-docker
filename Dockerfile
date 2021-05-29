FROM php:7.4-fpm-alpine

# update && install nginx 
RUN apk update && apk add nginx && \
    mkdir -p /run/nginx && \
    # forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log 

# INSTALL PHP EXTENCIONS
RUN apk add --no-cache autoconf make g++ && \
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
    docker-php-ext-install zip opcache\
    bcmath \
    mysqli \
    pdo_mysql \
    exif \
    intl && \
    # Remove builder depencences
    apk del --no-cache autoconf make g++

#CONFIGS
#copying cofings: nginx php-fpm
COPY php-fpm.conf nginx.conf default.nginx.conf opcache.ini ./

# Create App user
RUN adduser -u 1000 -G root -D app && \
    chown -R app:root /run/nginx/ && \
    chown -R app:root /var/lib/nginx/ && \
    chown -R app:root /var/log/nginx/ && \
    chown -R app:root /var/log/ && \
    # give permisions to socket dir
    chown -R app /var/run/ &&\
    # Feed configs
    mkdir -p /etc/nginx/conf.d/default/ && \
    echo "" > /usr/local/etc/php-fpm.d/zz-docker.conf &&  \
    cat php-fpm.conf > /usr/local/etc/php-fpm.d/www.conf &&  \
    cat nginx.conf > /etc/nginx/nginx.conf && \
    cat opcache.ini >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    mv default.nginx.conf /etc/nginx/conf.d/default.conf && \
    # remove config from here
    rm -rf php-fpm.conf nginx.conf default.nginx.conf opcache.ini && \ 
    mkdir /app && \
    chown -R app /app


USER app

WORKDIR /app

EXPOSE 8000

STOPSIGNAL SIGQUIT

ENTRYPOINT docker-php-entrypoint php-fpm -D -R && nginx -g "daemon off;"
