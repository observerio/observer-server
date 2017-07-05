#!/bin/bash

if [ ! -f auth/htpasswd ]; then

  if ! type "docker" > /dev/null; then

    echo "Docker is not installed on your local machine; this is required to create the htpasswd file automatically. Either install and re-run this script, or create the file using your preferred method." && \
    exit 1;
  else

    if [ -s "auth/registry_auth" ]
    then

      echo 'BEGIN generate creds by using registry_auth'

      for cred in `cat auth/registry_auth | awk '{print $2}'`; do
        echo `docker run --entrypoint htpasswd registry:2 -Bbn \`grep $cred auth/registry_auth | awk '{print $1}'\` $cred` >> auth/htpasswd;
      done

      echo 'DONE generate creds by using registry_auth'

    else
      echo "registry_auth file not found." && exit 1;
    fi

  fi

else

  echo "existing htpasswd found."

fi
