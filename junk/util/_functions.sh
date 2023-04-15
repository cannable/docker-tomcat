# ------------------------------------------------------------------------------
# Generic Function Definitions
# ------------------------------------------------------------------------------
# Override any of these in _build_env.sh.


build() {
    local arch=$1

    echo Building $arch...
    buildah bud --arch "$arch" --tag "${IMAGE}:${arch}-${version}" --build-arg "${VERSION_ARG}=${version}" -f ./Dockerfile .
}

mkmanifest() {
    local ver=$1
    local target=$2

    echo "Creating manifest: ${IMAGE}:${ver}"
    buildah manifest create "${IMAGE}:${ver}"

    for arch in ${ARCHES[@]}; do
        buildah manifest add "${IMAGE}:${ver}" "docker://${target}/${IMAGE}:${arch}-${ver}"
    done

    buildah manifest push -f v2s2 "${IMAGE}:${ver}" "docker://${target}/${IMAGE}:${ver}"

    buildah manifest rm "${IMAGE}:${ver}"
}

push_image() {
    local ver=$1
    local target=$2

    for arch in ${ARCHES[@]}; do
        echo "Source:      ${IMAGE}:${arch}-${ver}"
        echo "Destination: ${target}${IMAGE}:${arch}-${ver}"
        buildah push -f v2s2 "${IMAGE}:${arch}-${ver}" "${target}${IMAGE}:${arch}-${ver}"
    done
}