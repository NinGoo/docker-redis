all: build

build:
	@docker build --tag=ningoo/redis:latest .

release: build
	@docker build --tag=ningoo/redis:$(shell cat VERSION) .
