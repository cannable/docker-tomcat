#!/bin/bash

. "$(dirname $(readlink -f $0))/_functions.sh"
. "$(dirname $(dirname $(readlink -f $0)))/_build_env.sh"

if [[ $# -ne 2 ]]; then
    echo Create a manifest on the Docker Hub
    echo manifest_reg.sh version registry
    exit 1
fi

version=$1
target=$2

mkmanifest $version $target
