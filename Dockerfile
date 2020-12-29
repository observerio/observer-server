FROM elixir:1.11.2-alpine

RUN apk update
RUN apk add --force jq \
 && apk add --force putty \
 && apk add --force curl curl-dev \
 && apk add --force make \
 && apk add --force erlang-dev \
 && apk add --force git \
 && apk add --force musl \
 && apk add --force musl-dev \
 && apk add --force gcc

RUN mix do local.hex --force, local.rebar --force

# cleanup
RUN rm -rf /var/cache/apk/*

EXPOSE 8080

EXPOSE 4000
EXPOSE 4001
EXPOSE 4002

EXPOSE 6666
EXPOSE 6667
EXPOSE 6668

WORKDIR /app
