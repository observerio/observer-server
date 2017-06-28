#!/bin/bash

function generate_registry_keys {
  echo "Creating certs for $@..." && \
  openssl genrsa -out certs/registry.key 2048 && \
  openssl req -subj "/C=US/ST=NY/L=Flavortown/O=Guy Fieri/OU=Development Registry/CN=$@" -new -key certs/registry.key -out certs/registry.csr && \
  openssl x509 -req -in certs/registry.csr -CA certs/ca.crt -CAkey certs/ca.key -CAcreateserial -out certs/registry.crt -days 500 -sha256
}

if [ ! -f certs/registry.key ]; then
  type openssl >/dev/null 2>&1 || { echo >&2 "OpenSSL is required on your local machine to generate the CA."; exit 1; }

  if [ ! -f registry_auth ]; then
    echo "No registry_auth present"
  else
    generate_registry_keys $@
  fi
else
  echo -e "Registry cert present. Not replacing."
fi
