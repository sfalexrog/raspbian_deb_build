#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo "Running raspberrypi-kbuild docker image (if this fails, run create-docker.sh)"

docker run --rm -v ${DIR}:${DIR} raspberrypi-kbuild:latest /bin/bash -c "${DIR}/build.sh"
