NAME = api
SERVERS = 162.243.84.159

remove: stop
	docker-compose rm --force
.PHONY: remove

build: stop
	docker-compose up -d
.PHONY: build

rebuild: remove build

stop:
	docker-compose stop
.PHONY: stop

test:
	docker exec -ti `docker-compose ps -q $(NAME)` /bin/ash -c "mix test $(TEST_CASE)"
.PHONY: test

container.test:
	mix dogma && mix test
.PHONY: container.test

console:
	docker exec -ti `docker-compose ps -q $(NAME)` /bin/ash
.PHONY: console

server:
	/bin/sh make.sh server
.PHONY: server

simulate:
	/bin/sh make.sh simulate
.PHONY: simulate

watch.server:
	watchman-make -p 'lib/**/*.ex' 'test/**/*.exs' 'config/*.exs' 'mix.exs' -t server
.PHONY: watch.server

watch.test:
	watchman-make -p 'lib/**/*.ex' 'test/**/*.exs' 'config/*.exs' 'mix.exs' -t container.test
.PHONY: watch.test
