# ------------------------------------------------------------------------------
# Generic Function Definitions
# ------------------------------------------------------------------------------
# Override any of these in _build_env.sh.


build() {
    arch=$1

    echo Building $arch...
    buildah bud --arch "$arch" --tag "${IMAGE}:${arch}-${version}" --build-arg "${VERSION_ARG}=${version}" -f ./Dockerfile .
}

mkmanifest() {
    target=$1
    version=$2

    echo "Creating manifest: ${IMAGE}:${version}"
    buildah manifest create "${IMAGE}:${version}"

    for arch in ${ARCHES[@]}; do
        buildah manifest add "${IMAGE}:${version}" "docker://${target}/${IMAGE}:${arch}-${version}"
    done

    buildah manifest push -f v2s2 "${IMAGE}:${version}" "docker://${target}/${IMAGE}:${version}"

    buildah manifest rm "${IMAGE}:${version}"
}

push_image() {
    target=$1

    for arch in ${ARCHES[@]}; do
        echo "Source:      ${IMAGE}:${arch}-${version}"
        echo "Destination: ${target}${IMAGE}:${arch}-${version}"
        buildah push -f v2s2 "${IMAGE}:${arch}-${version}" "${target}${IMAGE}:${arch}-${version}"
    done
}