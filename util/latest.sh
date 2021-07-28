#!/bin/bash

. "$(dirname $(readlink -f $0))/_functions.sh"
. "$(dirname $(dirname $(readlink -f $0)))/_build_env.sh"

if [[ $# -ne 1 ]]; then
    echo Make an existing tag latest.
    echo latest.sh version
    exit 1
fi

version=$1

hub_manifest "latest"
