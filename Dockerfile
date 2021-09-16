ARG PHP_VERSION
FROM markdomkan/laravel-tools:php${PHP_VERSION}

#copying cofings: xdebug nginx php-fpm
COPY xdebug.ini php-fpm.conf nginx.conf default.nginx.conf opcache.ini ./

# Create App user
RUN adduser -u 1000 -G root -D app && \
    # update && install nginx 
    apk update && apk add nginx && \
    mkdir -p /run/nginx && \
    # forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log && \
    ## Install Xdebug
    apk add --no-cache autoconf make g++ && \
    pecl install xdebug && \
    docker-php-ext-enable xdebug  && \
    docker-php-ext-install zip opcache &&\
    # Remove builder depencences
    apk del --no-cache autoconf make g++ && \
    # Give permisions on App user
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
    mv default.nginx.conf /etc/nginx/conf.d/default.conf && \
    cat opcache.ini >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini && \
    cat xdebug.ini >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    # remove config files from here
    rm -rf xdebug.ini php-fpm.conf nginx.conf default.nginx.conf opcache.ini && \
    # creates vendor and node_modules folders and gives permisions to app user
    mkdir -p /app/vendor/ && \
    mkdir -p /app/node_modules/ && \
    chown -R app /app

USER app

RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)"

USER root

RUN sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd

USER app

EXPOSE 8000

STOPSIGNAL SIGQUIT

ENTRYPOINT docker-php-entrypoint php-fpm -D -R && nginx -g "daemon off;"
