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

# cleanup
RUN rm -rf /var/cache/apk/*

WORKDIR /app

EXPOSE 4200
EXPOSE 49153
