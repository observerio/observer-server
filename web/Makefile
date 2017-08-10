NAME = web

release:
	docker build --file Dockerfile.build -t observer_web_build . && \
	docker run -it -v `pwd`:/app -w /app observer_web_build /bin/ash -c "yarn && ember build --environment=production" && \
	docker build --file Dockerfile.release -t observer_web:release . && \
	docker tag observer_web:release docker-registry.rubyforce.co:5000/observer/observer_web:$(VERSION) && \
	docker push docker-registry.rubyforce.co:5000/observer/observer_web:$(VERSION) && \
	docker tag observer_web:release docker-registry.rubyforce.co:5000/observer/observer_web:latest && \
	docker push docker-registry.rubyforce.co:5000/observer/observer_web:latest
.PHONY: release
