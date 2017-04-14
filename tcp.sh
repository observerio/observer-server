#!/bin/sh

KEY=a643cfc76be5

redis-cli SET $KEY 1

(
printf "v:$KEY\n"
sleep 1
printf "i:$KEY:W3sidmFsdWUiOiJleGFtcGxlIiwidHlwZSI6InN0cmluZyIsIm5hbWUiOiJ0ZXN0aW5nMSJ9LHsidmFsdWUiOiItMSIsInR5cGUiOiJpbnRlZ2VyIiwibmFtZSI6InRlc3RpbmcyIn1d\n"
sleep 1
printf "l:$KEY:W3sidGltZXN0YW1wIjoxMjMxMjMxMjMsIm1lc3NhZ2UiOiJ0ZXN0aW5nMSJ9LHsidGltZXN0YW1wIjoxMjMxMjMxMjMsIm1lc3NhZ2UiOiJ0ZXN0aW5nMiJ9XQ==\n"
) | telnet localhost 6667
