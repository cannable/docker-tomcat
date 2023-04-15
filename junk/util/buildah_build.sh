#/bin/bash

. "$(dirname $(readlink -f $0))/_functions.sh"
. "$(dirname $(dirname $(readlink -f $0)))/_build_env.sh"

# Build phase

for arch in ${ARCHES[@]}; do
    build $arch
done