#!/bin/bash

. ./util/_functions.sh
. ./_build_env.sh

if [[ $# -ne 1 ]]; then
    echo Push images to external Docker registry
    echo push.sh registry
    exit 1
fi

registry=$1

# Create architecture tags
for ver in ${TC_VERSIONS[@]}; do

    mkmanifest "${ver}" "${registry}"

done

# Create major-version tags
for ver in ${TC_VERSIONS[@]}; do

    major_ver=$(echo $ver | awk -F . -e '{print $1}')

    buildah manifest create "${IMAGE}:${major_ver}"

    for arch in ${ARCHES[@]}; do
        buildah manifest add "${IMAGE}:${major_ver}" "docker://${registry}/${IMAGE}:${arch}-${ver}"
    done

    buildah manifest push -f v2s2 "${IMAGE}:${major_ver}" "docker://${registry}/${IMAGE}:${major_ver}"
    buildah manifest rm "${IMAGE}:${major_ver}"
done
