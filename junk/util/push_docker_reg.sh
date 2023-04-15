#!/bin/bash

. "$(dirname $(readlink -f $0))/_functions.sh"
. "$(dirname $(dirname $(readlink -f $0)))/_build_env.sh"

if [[ $# -ne 2 ]]; then
    echo Push image to external Docker registry
    echo push.sh version registry
    exit 1
fi

version=$1
registry=$2

push_image "${version}" "docker://${registry}/"
