FROM elixir:latest

WORKDIR /app

RUN apt-get update
RUN apt-get install -y tmux jq telnet

ADD http://s3.amazonaws.com/s3.hex.pm/installs/1.1.0/hex-0.15.0.ez /tmp/
RUN mix archive.install --force /tmp/hex-0.15.0.ez

RUN mix local.hex --force

EXPOSE 8080
EXPOSE 4000
EXPOSE 6667
