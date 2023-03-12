#!/bin/bash

docker compose build --build-arg EMACS_VERSION=$1 ARCH=$2
docker compose up -d

RPM_PATH=$(docker exec tmux-rpm find ./work-dir/ | grep "work-dir/emacs.*rpm")
docker cp emacs-rpm:/root/"$RPM_PATH" .
