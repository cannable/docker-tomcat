# ------------------------------------------------------------------------------
# Ansible Container
# ------------------------------------------------------------------------------
# This container has Ansible and a few Dell and VMware modules installed.

IMAGE="cannable/tomcat"
JDK_MAJOR_VERSION=11
#ARCHES=(amd64 arm64)
ARCHES=(amd64)
#TC_VERSIONS=(7.0 8.0 8.5 9.0 10.0)
TC_VERSIONS=("10.0.8")
CATALINA_HOME=/opt/tomcat
NAME=HARDTC
TC_USER=tomcat
TC_UID=6060

# ------------------------------------------------------------------------------
# Function Definitions

cache() {
    fname=$1
    url=$2

    cachename="cache/${fname}"

    # Only download file if we need to
    if [ ! -f "${cachename}" ]; then
        echo "Caching ${fname} (${url})..."
        curl -o "${cachename}" "${url}"
    fi

}

verify() {
    sig_file=$1

    sig_path="cache/${sig_file}"

    echo "Checking signature ($sig_file)..."
    gpg --verify "${sig_path}"

    if [[ $? -ne 0 ]]; then
        (>&2 echo --------------------------------------------------)
        (>&2 echo --------------------------------------------------)
        (>&2 echo URGENT: ${sig_file} DOES NOT MATCH PGP SIGNATURE!)
        (>&2 echo THIS IS NOT PARTICULARLY GOOD. CHECK YOUR DOWNLOAD.)
        (>&2 echo BUILD PROCESS TERMINATED. CONTAINER WILL NOT FUNCTION.)
        (>&2 echo --------------------------------------------------)
        (>&2 echo --------------------------------------------------)
        exit 1
    fi

}

build_common_base() {
    arch=$1

    c=$(buildah from --arch "$arch" alpine)
    buildah run $c apk update
    buildah run $c apk add --no-cache \
        dumb-init \
        "openjdk${JDK_MAJOR_VERSION}-jre-headless"
    buildah run $c apk cache clean
    buildah commit --format docker --rm $c "${IMAGE}:${arch}-common-base"
}

build_image() {
    arch=$1
    ver=$2

    pkgname="apache-tomcat-${ver}"
    filename="apache-tomcat-${ver}.tar.gz"
    webapps="${CATALINA_HOME}/webapps"

    c=$(buildah from --arch "$arch" "${IMAGE}:${arch}-common-base")

    # Copy over the artefacts
    buildah copy $c "cache/${filename}" /tmp
    buildah copy $c "cache/${filename}.asc" /tmp

    buildah run $c tar -xzf "/tmp/${filename}" -C /tmp/
    buildah run $c mv "/tmp/${pkgname}/" "${CATALINA_HOME}"

    buildah run $c rm -f \
        "/tmp/${filename}" \
        "/tmp/${filename}.asc"


    # Prune default webapps
    echo Pruning default webapps...
    buildah run $c rm -rf "${webapps}/docs"
    buildah run $c rm -rf "${webapps}/examples"
    buildah run $c rm -rf "${webapps}/host-manager"
    buildah run $c rm -rf "${webapps}/ROOT"
    #buildah run $c rm -rf "${webapps}/manager"

    buildah run $c mkdir /data

    buildah copy \
        --chown root:root \
        --chmod 0755 \
        $c data/init.sh /data/init.sh

    buildah copy \
        --chown root:root \
        --chmod 0644 \
        $c data/firstrun /data/firstrun

    buildah config  \
        --env "NAME=${NAME}" \
        --env "TC_USER=${TC_USER}" \
        --env "TC_UID=${TC_UID}" \
        --env "CATALINA_HOME=${CATALINA_HOME}" \
        --volume "$CATALINA_HOME/conf" \
        --volume "$CATALINA_HOME/logs" \
        --volume "$CATALINA_HOME/temp" \
        --volume "$CATALINA_HOME/webapps" \
        --volume "$CATALINA_HOME/work" \
        --port 8443 \
        --port 8080 \
        --workingdir "${CATALINA_HOME}" \
        --entrypoint '["/usr/bin/dumb-init", "--"]' \
        --cmd "/bin/bash /data/init.sh"  \
        $c

    buildah commit --format docker --rm $c "${IMAGE}:${arch}-${ver}"
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
    # Generate URLs
    major_ver=$(echo $ver | awk -F . -e '{print $1}')
    url_keys="https://downloads.apache.org/tomcat/tomcat-${major_ver}/KEYS"

    pkgname="apache-tomcat-${ver}"
    filename="apache-tomcat-${ver}.tar.gz"

    url_bin="https://archive.apache.org/dist/tomcat/tomcat-${major_ver}/v${ver}/bin/${filename}"
    url_sig="${url_bin}.asc"

    # Import keys
    echo Importing the Apache Tomcat PGP KEYS...
    curl ${url_keys} | gpg --import -

    # Download tar archive and signature, if we need to
    cache $filename $url_bin
    cache "${filename}.asc" $url_sig

    # Check signature
    verify "${filename}.asc"
done


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