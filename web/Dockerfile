FROM mhart/alpine-node:7.9.0

RUN \
  apk add --no-cache \
  g++ \
  gcc \
  make \
  git \
  python \
  && git clone https://github.com/sass/sassc \
  && cd sassc \
  && git clone https://github.com/sass/libsass \
  && SASS_LIBSASS_PATH=/sassc/libsass make \
  && mv /sassc/bin/sassc /usr/bin/sass

# cleanup
RUN rm -rf /var/cache/apk/* && rm -rf /sassc

# Install (global) NPM packages/dependencies
RUN npm install --ignore-optional -g \
  node-gyp \
  pm2 \
  yarn

WORKDIR /app

EXPOSE 5001
