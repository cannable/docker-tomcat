# ------------------------------------------------------------------------------
# Build Everything
# ------------------------------------------------------------------------------
# This script will build all images.

# NOTE: You should use this, first, before the build script under util, because
# this will cache all the required bits.

. ./util/_functions.sh
. ./_build_env.sh


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
    build $arch
done