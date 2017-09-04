HTTP_HOST=localhost:8080
KEY=${KEY:-55278729d2f1}

echo `curl -v -H "Content-Type: application/json" -X GET "http://$HTTP_HOST/users/tokens"`
echo `curl -v -H "Content-Type: application/json" -d '{"token":"'$KEY'"}' -X POST "http://$HTTP_HOST/users/tokens"`
