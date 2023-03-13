#!/bin/bash

docker compose build --build-arg TMUX_VERSION="$1" --build-arg ARCH="$2"
docker compose up -d

RPM_PATH=$(docker exec tmux-rpm find ./work-dir/ | grep "work-dir/tmux.*rpm")
docker cp tmux-rpm:/root/"$RPM_PATH" .
