# ------------------------------------------------------------------------------
# Ansible Container
# ------------------------------------------------------------------------------
# This container has Ansible and a few Dell and VMware modules installed.

IMAGE="cannable/tomcat"
#ARCHES=(amd64 arm64)
ARCHES=(amd64)
#TC_VERSIONS=(7.0 8.0 8.5 9.0 10.0)
TC_VERSIONS=("8.5")

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