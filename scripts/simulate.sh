#!/bin/sh

HTTP_HOST=${HTTP_HOST:-https://observer.rubyforce.co/api}
TCP_HOST=${TCP_HOST:-observer.rubyforce.co}
TCP_PORT=${TCP_PORT:-30001}

SLEEP_TIME=20
COMMAND_SLEEP_TIME=5

until $(curl --output /dev/null --silent --fail -X GET $HTTP_HOST/alive); do
    printf '.'
    sleep 5
done

KEY=${KEY:-0752b7baffd0}
# KEY=`curl $HTTP_HOST/users/tokens | jq .token | sed 's/"\([^"]*\)"/\1/'`
# `curl -H "Content-Type: application/json" -d "'{"token":"'$KEY'"}'" -X POST "http://$HTTP_HOST/api/users/tokens"`

echo "Settings: http: ${HTTP_HOST}, tcp host: ${TCP_HOST}, tcp port: ${TCP_PORT}"

while true
do
  (
    printf "v:$KEY\n"
    sleep $COMMAND_SLEEP_TIME
    printf "i:$KEY:W3sidmFsdWUiOiJleGFtcGxlIiwidHlwZSI6InN0cmluZyIsIm5hbWUiOiJ0ZXN0aW5nMSJ9LHsidmFsdWUiOiItMSIsInR5cGUiOiJpbnRlZ2VyIiwibmFtZSI6InRlc3RpbmcyIn1d\n"
    sleep $COMMAND_SLEEP_TIME
    printf "l:$KEY:W3sidGltZXN0YW1wIjoxMjMxMjMxMjMsIm1lc3NhZ2UiOiJ0ZXN0aW5nMSJ9LHsidGltZXN0YW1wIjoxMjMxMjMxMjMsIm1lc3NhZ2UiOiJ0ZXN0aW5nMiJ9XQ==\n"
  ) | telnet $TCP_HOST $TCP_PORT

  sleep $SLEEP_TIME
done
