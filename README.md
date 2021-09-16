# Container with all necessary to develop laravel

This image contains a all necessary to serve laravel framework app in development environment. Is based on [markdomkan/laravel-tools](https://hub.docker.com/r/markdomkan/laravel-tools) image, and contains all of these tools and requirements plus:

- **php**: (config your version with --build-arg PHP_VERSION); with **xdebug** on port 9001
- **nginx**: for serve your app


example of **.vscode/lauch.json** for debug:
```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for XDebug",
            "type": "php",
            "request": "launch",
            "port": 9001,
            "hostname": "0.0.0.0",
             "pathMappings": {
                "/app/": "${workspaceFolder}/",
            }
        }
    ]
}

```
example of full **docker-compose.yml**:
```yml
version: "3.7"
services:
  app:
    container_name: example-app
    image: markdomkan/laravel-bundle:php8.0-dev
    ports:
      - 8000:8000
    volumes:
      - ./:/app
      # optional
      - ./docker/php.ini:/usr/local/etc/php/conf.d/local.ini
      # optional
      - ./docker/nginx.conf:/etc/nginx/conf.d/default/server.conf
    networks:
      - example
    extra_hosts:
      # necessary for xdebug
      - host.docker.internal: YOUR_LOCAL_MACHINE_IP

  db:
    image: mysql:8.0
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
