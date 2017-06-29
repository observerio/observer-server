#!/bin/bash

if [ ! -f auth/htpasswd ]; then

  if ! type "docker" > /dev/null; then

    echo "Docker is not installed on your local machine; this is required to create the htpasswd file automatically. Either install and re-run this script, or create the file using your preferred method." && \
    exit 1;
  else

    if [ -s "registry_auth" ]
    then

      for cred in `cat registry_auth | awk '{print $2}'`; do
        echo `docker run --entrypoint htpasswd registry:2 -Bbn \`grep $cred registry_auth | awk '{print $1}'\` $cred` >> auth/htpasswd;
      done

    else
      echo "registry_auth file not found." && exit 1;
    fi

  fi

else

  echo "existing htpasswd found."

fi
