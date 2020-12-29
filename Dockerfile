FROM bitwalker/alpine-elixir:1.11.2

RUN echo '' > /etc/apk/repositories && \
  echo 'http://nl.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories && \
  echo 'http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories

RUN apk update
RUN apk add --force jq \
 && apk add --force putty \
 && apk add --force curl curl-dev \
 && apk add --force make \
 && apk add --force erlang-dev

RUN apk add --force musl
RUN apk add --force musl-dev
RUN apk add --force alpine-sdk

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
