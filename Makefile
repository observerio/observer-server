NAME = api
SERVERS = 162.243.84.159

remove: stop
	docker-compose rm --force
.PHONY: remove

build: stop
	docker-compose up -d
.PHONY: build

restart.api:
	docker-compose restart api && docker-compose logs -f --tail=1 api
.PHONY: restart.api

restart.sim:
	docker-compose restart simulate && docker-compose logs -f --tail=1 simulate
.PHONY: restart.sim

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
	docker-compose exec -ti `docker-compose ps -q $(NAME)` /bin/ash -c "watchman-make -p 'lib/**/*.ex' 'test/**/*.exs' 'config/*.exs' 'mix.exs' -t container.test"
.PHONY: watch.test

release:
	mix docker.build && mix docker.release
	docker tag observer_api:$VERSION docker-registry.rubyforce.co:5000/observer/observer_api:$VERSION
	docker push observer_api:$VERSION
.PHONY: release
