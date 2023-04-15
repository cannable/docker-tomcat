#!/bin/bash

. ./util/_functions.sh
. ./_build_env.sh

if [[ $# -ne 1 ]]; then
    echo Push images to external Docker registry
    echo push.sh registry
    exit 1
fi

registry=$1

for ver in ${TC_VERSIONS[@]}; do

    push_image "${ver}" "docker://${registry}/"

done
