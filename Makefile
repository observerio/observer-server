NAME = observer
SERVERS = 162.243.84.159

remove: stop
	docker-compose rm --force
.PHONY: remove

build: stop
	docker-compose up -d
.PHONY: build

deploy:
	mix edeliver stop production
	mix edeliver build release --version=$(RELEASE_VERSION)
	mix edeliver deploy release to production --verbose --version=$(RELEASE_VERSION)
	mix edeliver start production --verbose --version=$(RELEASE_VERSION)
.PHONY: deploy

restart:
	mix edeliver stop production
	mix edeliver start production --verbose --version=$(RELEASE_VERSION)
.PHONY: restart

stop:
	docker-compose stop
.PHONY: stop

test:
	docker exec -ti `docker-compose ps -q $(NAME)` /bin/ash -c "mix test $(TEST_CASE)"
.PHONY: test

console:
	docker exec -ti `docker-compose ps -q $(NAME)` /bin/ash
.PHONY: console
