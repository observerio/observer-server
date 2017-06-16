FROM bitwalker/alpine-elixir:1.4.2

RUN apk update \
 && apk add jq \
 && apk add putty \
 && apk add curl \
 && apk add make \
 && apk add --update alpine-sdk \
 && apk add erlang-dev \
 && rm -rf /var/cache/apk/*

EXPOSE 8080
EXPOSE 4000
EXPOSE 6667

WORKDIR /app
