# ------------------------------------------------------------------------------
# Tomcat Container
# ------------------------------------------------------------------------------
# A container image with Tomcat and a few hardening tweaks.

# ------------------------------------------------------------------------------
# Environment

# Build-time variables

IMAGE="cannable/tomcat"
ARCHES=(amd64 arm64)

TC_VERSIONS=("8.5.71" "9.0.53" "10.0.11")
JDK_MAJOR_VERSION=11

LOG4J2_ENABLED=1
LOG4J2_VERSION=2.14.1

# Run-time variables

CATALINA_HOME=/opt/tomcat
NAME=HARDTC
TC_USER=tomcat
TC_UID=6060

# ------------------------------------------------------------------------------
# Function Definitions

cache() {
    local fname=$1
    local url=$2

    cachename="cache/${fname}"

    # Only download file if we need to
    if [ -f "${cachename}" ]; then
        echo "${fname} is already cached. Not downloading."
    else
        echo "Caching ${fname} (${url})..."
        curl -o "${cachename}" "${url}"
    fi

}

verify() {
    local sig_file=$1

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

build() {
    echo Building common-base image for $arch...
    build_common_base $arch

    for ver in ${TC_VERSIONS[@]}; do

        build_image $arch $ver

    done
    
    podman image rm "${IMAGE}:${arch}-common-base"

}

build_common_base() {
    local arch=$1

    c=$(buildah from --arch "$arch" alpine)
    buildah run $c apk update
    buildah run $c apk add --no-cache \
        dumb-init \
        "openjdk${JDK_MAJOR_VERSION}-jre-headless"
    buildah run $c apk cache clean
    buildah commit --format docker --rm $c "${IMAGE}:${arch}-common-base"
}

build_image() {
    local arch=$1
    local ver=$2

    pkgname="apache-tomcat-${ver}"
    filename="apache-tomcat-${ver}.tar.gz"
    webapps="${CATALINA_HOME}/webapps"

    c=$(buildah from --arch "$arch" "${IMAGE}:${arch}-common-base")

    # Copy over the artefacts
    buildah copy $c "cache/${filename}" /tmp

    buildah run $c tar -xzf "/tmp/${filename}" -C /tmp/
    buildah run $c mv "/tmp/${pkgname}/" "${CATALINA_HOME}"

    buildah run $c rm -f "/tmp/${filename}"

    # Prune default webapps
    echo Pruning default webapps...
    buildah run $c rm -rf "${webapps}/docs"
    buildah run $c rm -rf "${webapps}/examples"
    buildah run $c rm -rf "${webapps}/host-manager"
    buildah run $c rm -rf "${webapps}/ROOT"
    #buildah run $c rm -rf "${webapps}/manager"

    buildah run $c mkdir /data

    # setenv.sh redirection
    buildah copy $c data/setenv.sh "${CATALINA_HOME}/conf/setenv.sh"

    buildah run $c ln -s "${CATALINA_HOME}/conf/setenv.sh" "${CATALINA_HOME}/bin/setenv.sh"

    buildah copy \
        --chown root:root \
        --chmod 0755 \
        $c data/init.sh /data/init.sh

    if [ "$LOG4J2_ENABLED" -gt "0" ]; then
        install_log4j $c $LOG4J2_VERSION
    fi

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
        --cmd "/bin/sh /data/init.sh"  \
        $c

    buildah commit --format docker --rm $c "${IMAGE}:${arch}-${ver}"
}

get_tomcat() {
    local ver=$1

    # Generate URLs
    local major_ver=$(echo $ver | awk -F . -e '{print $1}')

    local pkgname="apache-tomcat-${ver}"
    local filename="apache-tomcat-${ver}.tar.gz"

    local url="https://archive.apache.org/dist/tomcat/tomcat-${major_ver}/v${ver}/bin/${filename}"

    # Get signing key(s)
    import_pgp_keys "https://downloads.apache.org/tomcat/tomcat-${major_ver}/KEYS"

    # Download tar archive and signature, if we need to
    cache $filename $url
    cache "${filename}.asc" "${url}.asc"

    # Check signature
    verify "${filename}.asc"
}

get_log4j() {
    local ver=$1

    local filename="apache-log4j-${ver}-bin.tar.gz"
    local url="https://archive.apache.org/dist/logging/log4j/${ver}/${filename}"

    import_pgp_keys "https://downloads.apache.org/logging/KEYS"

    cache $filename $url
    cache "${filename}.asc" "${url}.asc"

    verify "${filename}.asc"
}

install_log4j() {
    local c=$1
    local ver=$2

    local ver=2.14.1
    local dirname=apache-log4j-${ver}-bin
    local filename="${dirname}.tar.gz"

    echo Installing Log4j ${ver}...

    buildah copy $c "cache/${filename}" /tmp

    buildah run $c mkdir -p \
        "${CATALINA_HOME}/log4j2/conf" \
        "${CATALINA_HOME}/log4j2/lib"

    for jar in log4j-api log4j-core log4j-appserver; do

        buildah run $c tar -xzf "/tmp/${filename}" \
            -C "/tmp" \
            "${dirname}/${jar}-${ver}.jar"

        buildah run $c mv "/tmp/${dirname}/${jar}-${ver}.jar" "${CATALINA_HOME}/log4j2/lib"
    done

    buildah run $c rm -rf "/tmp/${filename}" "/tmp/${dirname}"

    buildah copy $c "log4j2/setenv.sh" "${CATALINA_HOME}/conf"
    buildah copy $c "log4j2/log4j2-tomcat.xml" "${CATALINA_HOME}/conf"
    buildah run $c ln -s "${CATALINA_HOME}/conf/log4j2-tomcat.xml" "${CATALINA_HOME}/log4j2/conf/log4j2-tomcat.xml"

    buildah run $c rm "${CATALINA_HOME}/conf/logging.properties"

}

import_pgp_keys() {
    local url=$1

    # Import keys
    echo Importing PGP keys from ${url}
    curl ${url} | gpg --import -
}
