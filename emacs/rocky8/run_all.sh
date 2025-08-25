#!/bin/bash

docker pull rockylinux:8
docker compose build --build-arg EMACS_VERSION="$1" --build-arg ARCH="$2"
docker compose up -d

RPM_PATH=$(docker exec emacs-rpm find ./work-dir/ | grep "work-dir/emacs.*rpm$")
docker cp emacs-rpm:/root/"$RPM_PATH" .
