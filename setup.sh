#!/bin/sh

set -x

# docker network create --subnet=10.0.0.0/24 --gateway=10.0.0.1 dockitt_network

PWD=$(pwd)
needENV="bookstack drone gitea"

for service in $needENV; do
    if [ -d "$PWD/$service" ]; then
        cd "$PWD/$service" || exit
        ln -sf "$PWD/.env.example" "$PWD/$service/.env"
    fi
done
