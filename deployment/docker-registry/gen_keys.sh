#!/bin/bash

set -e

if [ -z "$1" ]; then
  $1 = 1
fi

echo -e "Generating credentials for $1 user(s)\n"

OPENSSL_PATH=/System/Library/OpenSSL/openssl.cnf

function generate_CA {
  echo 'begin generate CA'
  openssl genrsa -out certs/ca.key 2048 && openssl req -subj "/C=US/ST=NY/L=Flavortown/O=Guy Fieri/OU=Development CA" -config $OPENSSL_PATH -new -key certs/ca.key -x509 -days 1825 -out certs/ca.crt
  echo 'done generate CA'
}

function generate_creds {
  echo 'begin generate creds'
  if [ ! -f auth/htpasswd ]; then
    echo 'begin generate creds no htpasswd'
    for ((n=0;n<$1;n++)); do echo "imgadm-$n " "`date +%s | shasum -a 256 | base64 | head -c 32 ; echo`" >> auth/registry_auth && sleep 1; done
    echo 'done generate creds no htpasswd'
  else
    echo "auth/htpasswd exists; no new credentials being created."
  fi
  echo 'done generate creds'
}

if [ -s "auth/registry_auth" ]
then
  echo "auth/registry_auth file not empty"
else
  generate_creds $1
fi

if [ ! -f ca.key ]; then

  type openssl >/dev/null 2>&1 || { echo >&2 "OpenSSL is required on your local machine to generate the CA."; exit 1; }

  if [ ! -f auth/registry_auth ]; then
      echo "auth/registry_auth could not be found. Creating..."

      echo "begin generating creds ..."
      generate_creds
      echo "done generating creds ..."

      echo "begin generating CA ..."
      generate_CA
      echo "done generating CA ..."
  else
    echo "Generating CA certificate in `pwd`/ca.crt..." && \
    generate_CA
  fi

else
    echo "CA key and cert already exist. Skipping..."
fi

echo "DONE gen_keys.sh"
