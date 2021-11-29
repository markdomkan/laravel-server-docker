versions=7.2 7.3 7.4 8.0

all:
	$(foreach version, $(versions), $(shell docker buildx build --platform linux/amd64,linux/arm64 --pull --push --rm -t markdomkan/laravel-server:php$(version)-dev --build-arg PHP_VERSION=$(version) .))
