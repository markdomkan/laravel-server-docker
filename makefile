versions=7.2 7.3 7.4 8.0

all:
	$(foreach version, $(versions), $(shell docker build --pull --rm -t markdomkan/laravel-server:php$(version)-dev --build-arg PHP_VERSION=$(version) .))
