versions=7.2 7.3 7.4 8.0

all:
	$(foreach version, $(versions), $(shell docker build --platform linux/amd64 --pull --rm -t markdomkan/laravel-server:php$(version)-dev --build-arg PHP_VERSION=$(version) .))
	$(foreach version, $(versions), $(shell docker build --platform linux/arm64 --pull --rm -t markdomkan/laravel-server:php$(version)-dev-arm64 --build-arg PHP_VERSION=$(version)-arm64 .))
