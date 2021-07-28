#!/bin/bash

. "$(dirname $(readlink -f $0))/_functions.sh"
. "$(dirname $(dirname $(readlink -f $0)))/_build_env.sh"

if [[ $# -ne 1 ]]; then
    echo Push image to local Docker
    echo push.sh version
    exit 1
fi

version=$1

push_image "docker-daemon:"
