# Container with all necessary to develop laravel

This image contains a all necessary to develop laravel framework

- **php**: 8.0; with **xdebug** on port 9001
- **node**: 12.x with **yarn**;
- **nginx**

example of docker-compose.yml:

```yml
version: "3.7"
services:
  app:
    container_name: example-app
    image: markdomkan/laravel-bundle:php8
    ports:
      - 8000:80
    volumes:
      - ./:/www
      # optional
      - ./docker/php.ini:/usr/local/etc/php/conf.d/local.ini
      # optional
      - ./docker/nginx.conf:/etc/nginx/conf.d/default/server.conf
    networks:
      - example
    extra_hosts:
      # necessary for xdebug
      - host.docker.internal: YOUR_LOCAL_IP

  db:
    image: mysql:8.0.19
    container_name: example-db
    command: --default-authentication-plugin=mysql_native_password
    environment:
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_USER: ${DB_USERNAME}
    ports:
      - 3306:3306
    volumes:
      - example:/var/lib/mysql/
    networks:
      - example

networks:
  example:
    driver: bridge

volumes:
  example:
    name: example-db
    driver: local

```

For php and nginx custom php configuration (optional):

docker/nginx.conf:

```conf
client_max_body_size 8M;
```

docker/php.ini:

```ini
upload_max_filesize=40M
post_max_size=40M
memory_limit=-1
```
