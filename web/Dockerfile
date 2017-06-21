FROM mhart/alpine-node:7.9.0

RUN \
  apk add --no-cache \
  g++ \
  gcc \
  make \
  git \
  python

# Install (global) NPM packages/dependencies
RUN npm install --ignore-optional -g \
  node-gyp \
  pm2 \
  yarn

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

WORKDIR /app

EXPOSE 4200
EXPOSE 49153
