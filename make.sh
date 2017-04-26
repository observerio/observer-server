COMMAND=$1

help() {
  echo "-----------------------------------------------------------------------"
  echo "                      Available commands                              -"
  echo "-----------------------------------------------------------------------"
  echo "   > server - boot server in container"
  echo "   > simulate - run tcp commands via"
  echo "-----------------------------------------------------------------------"
}

server() {
  mix deps.get --all || true
  mix local.rebar --force || true
  iex -S mix
}

simulate() {
  /bin/sh tcp.sh
}

case $COMMAND in
  server )
    server
    ;;
  simulate )
    simulate
    ;;
  * )
    help
    ;;
esac
