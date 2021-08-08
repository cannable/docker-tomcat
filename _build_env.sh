# ------------------------------------------------------------------------------
# Tomcat Container
# ------------------------------------------------------------------------------
# A container image with Tomcat and a few hardening tweaks.

# ------------------------------------------------------------------------------
# Environment

# Build-time variables

IMAGE="cannable/tomcat"
ARCHES=(amd64 arm64)

TC_VERSIONS=("8.5.69" "9.0.52" "10.0.10")
JDK_MAJOR_VERSION=11

LOG4J2_ENABLED=1
LOG4J2_VERSION=2.14.1

# Run-time variables

CATALINA_HOME=/opt/tomcat
NAME=HARDTC
TC_USER=tomcat
TC_UID=6060

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