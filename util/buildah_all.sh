# ------------------------------------------------------------------------------
# Tomcat Container
# ------------------------------------------------------------------------------
# A container image with Tomcat and a few hardening tweaks.

. "$(dirname $(readlink -f $0))/_functions.sh"
. "$(dirname $(dirname $(readlink -f $0)))/_build_env.sh"


build() {

    arch=$1

    for version in ${TC_VERSIONS[@]}; do
        echo Building $arch...

        buildah bud \
            --format docker \
            --arch "$arch" \
            --build-arg "TC_VERSION=${version}" \
            --build-arg "JDK_MAJOR_VERSION=11" \
            -t "cannable/tomcat:${version}-micro" \
            -f "./Dockerfile" .

    done

}

# ------------------------------------------------------------------------------
# Sanity Checks

# TODO: Add sanity checks. LOL


# ------------------------------------------------------------------------------
# Download artefacts first
if [ ! -d cache ]; then
    mkdir cache
fi


for ver in ${TC_VERSIONS[@]}; do
    get_tomcat $ver
done

if [ "$LOG4J2_ENABLED" -gt "0" ]; then
    echo Log4j is enabled for this build.

    get_log4j $c $LOG4J2_VERSION
fi

# ------------------------------------------------------------------------------
# Build images


for arch in ${ARCHES[@]}; do
    echo Building common-base image for $arch...
    build_common_base $arch

    for ver in ${TC_VERSIONS[@]}; do

        build_image $arch $ver

    done
    
    podman image rm "${IMAGE}:${arch}-common-base"
done