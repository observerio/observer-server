NAME = api
DOCKER_PRIVATE_HOST=docker-registry.rubyforce.co:5000
DOCKER_COMPOSE=pipenv run docker-compose

init:
	(docker network create game-dev || true)
	pip install --user pipenv
	pipenv install
.PHONY: init

remove: stop
	$(DOCKER_COMPOSE) rm --force
.PHONY: remove

build: stop
	$(DOCKER_COMPOSE) up -d
.PHONY: build

restart.api:
	$(DOCKER_COMPOSE) restart api && $(DOCKER_COMPOSE) logs -f --tail=1 api
.PHONY: restart.api

restart.sim:
	$(DOCKER_COMPOSE) restart simulate && $(DOCKER_COMPOSE) logs -f --tail=1 simulate
.PHONY: restart.sim

rebuild: remove build

stop:
	$(DOCKER_COMPOSE) stop
.PHONY: stop

test:
	docker exec -ti `$(DOCKER_COMPOSE) ps -q $(NAME)` /bin/ash -c "mix test $(TEST_CASE)"
.PHONY: test

container.test:
	mix dogma && mix test
.PHONY: container.test

console:
	docker exec -ti `$(DOCKER_COMPOSE) ps -q $(NAME)` /bin/ash
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
	$(DOCKER_COMPOSE) exec -ti `$(DOCKER_COMPOSE) ps -q $(NAME)` /bin/ash -c "watchman-make -p 'lib/**/*.ex' 'test/**/*.exs' 'config/*.exs' 'mix.exs' -t container.test"
.PHONY: watch.test

# should rebuild image with api erlang app inside and then push it to our
# docker private registry.
api.release:
	mix docker.build && mix docker.release && \
	docker tag observer_api:release docker-registry.rubyforce.co:5000/observer/observer_api:$(VERSION) && \
	docker push $(DOCKER_PRIVATE_HOST)/observer/observer_api:$(VERSION) && \
	docker tag observer_api:release docker-registry.rubyforce.co:5000/observer/observer_api:latest && \
	docker push $(DOCKER_PRIVATE_HOST)/observer/observer_api:latest
	kubectl apply -f deployment/app-deploy/api
.PHONY: api.release

web.release:
	cd web/ && make release
.PHONY: web.release

release: api.release web.release
.PHONY: release
