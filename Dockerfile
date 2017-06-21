FROM bitwalker/alpine-elixir:1.4.2

RUN apk update \
 && apk add jq \
 && apk add putty \
 && apk add curl \
 && apk add make \
 && apk add --update alpine-sdk \
 && apk add erlang-dev

RUN apk add --no-cache \
  linux-headers \
  automake \
  autoconf \
  python-dev \
  py-pip \
  && git clone https://github.com/facebook/watchman.git \
  && cd watchman \
  && git checkout v4.7.0 \
  && ./autogen.sh \
  && ./configure  \
  && make \
  && make install \
  && pip install pywatchman

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
