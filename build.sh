#!/bin/bash

# ------------------------------------------------------------------------------
# Build Container Image
# ------------------------------------------------------------------------------
# This script provides some scaffolding to make building multiple images at once
# easier.

# ------------------------------------------------------------------------------
# Defaults

DEFAULT_BUILDER="buildah"
DEFAULT_BUILD_ARCH=""
DEFAULT_CACHE_DIR="./cache"
DEFAULT_DOCKER_FILE="./Dockerfile"
DEFAULT_JDK_MAJOR_VERSION=11
DEFAULT_TAG_POSTFIX=""
DEFAULT_TOMCAT_VERSION=9.0.73


# ------------------------------------------------------------------------------
# Function Definitions

# printUsage -- Print the customary help/usage blurb.
printUsage() {
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "The default builder is ${DEFAULT_BUILDER}."
    echo ""
    echo "Options:"
    echo "    -a arch      Set the architecture for build."
    echo "                 To use this for creating multiarch images, you need"
    echo "                 qemu-user-static set up properly."
    echo "    -b           Build with buildah."
    echo "    -c path      Set the artifact cache directory."
    echo "                 Defaults to ${DEFAULT_CACHE_DIR}"
    echo "    -d           Build with docker."
    echo "    -h           Print this help."
    echo "    -j ver       Set OpenJDK major version to build."
    echo "                 Defaults to ${DEFAULT_JDK_MAJOR_VERSION}"
    echo "    -p postfix   Append '-postfix' to the image tag"
    echo "    -t ver       Set Tomcat version to build."
    echo "                 Defaults to ${DEFAULT_TOMCAT_VERSION}"
    echo ""
}

# checkFileExists -- Confirm a file exists.
checkFileExists() {
    if [ -z $1 ]; then
        echo "checkFileExists: no argument passed."
        exit 1
    fi

    if [ ! -f $1 ]; then
        echo "FAIL: ${1} does not exist!"
        echo ""
        echo "Build terminated."
        exit 1
    fi
    echo "${1} exists."
}

# checkFileSignature -- Check file signature with GnuPG.
checkFileSignature() {
    if [ -z $1 ]; then
        echo "checkFileSignature: no argument passed."
        exit 1
    fi

    local filePath="${1}.asc"

    checkFileExists "$filePath"

    echo "Checking signature of artifact."
    echo "--- Begin: GnuPG Output ---------------------------------------------"

    gpg --verify "$filePath"
    local gpgExitStatus=$?

    echo "--- End: GnuPG Output -----------------------------------------------"

    if [ $gpgExitStatus -ne 0 ]; then
        echo "FAIL: Check of PGP signature failed. This is catastrophically bad"
        echo "and this script will exit. Possible causes include corruption of"
        echo "cached artifacts or a broken chain of trust in your GnuPG"
        echo "keyring. Check the output from GnuPG for clues."
        echo ""
        exit 2
    fi
}

# ------------------------------------------------------------------------------
# Handle command line arguments

BUILDER="${DEFAULT_BUILDER}"
BUILD_ARCH="${DEFAULT_BUILD_ARCH}"
CACHE_DIR="${DEFAULT_CACHE_DIR}"
DOCKER_FILE="${DEFAULT_DOCKER_FILE}"
JDK_MAJOR_VERSION="${DEFAULT_JDK_MAJOR_VERSION}"
TAG_POSTFIX="${DEFAULT_TAG_POSTFIX}"
TOMCAT_VERSION="${DEFAULT_TOMCAT_VERSION}"

while getopts "a:bc:df:hj:p:t:" opt; do
    case $opt in
        a)
            BUILD_ARCH="${OPTARG}"
            ;;
        b)
            BUILDER="buildah"
            ;;
        c)
            CACHE_DIR="${OPTARG}"
            ;;
        d)
            builder="docker"
            ;;
        f)
            DOCKER_FILE="${OPTARG}"
            ;;
        h)
            printUsage
            exit
            ;;
        j)
            JDK_MAJOR_VERSION="${OPTARG}"
            ;;
        p)
            TAG_POSTFIX="${OPTARG}"
            ;;
        t)
            TOMCAT_VERSION="${OPTARG}"
            ;;
        *)
            echo "Script argument processing failed."
            exit 1
            ;;
    esac
done


# ------------------------------------------------------------------------------
# Calculated Variables

TOMCAT_PKG_PATH="./cache/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
IMAGE_TAG="cannable/tomcat:${TOMCAT_VERSION}-openjdk${JDK_MAJOR_VERSION}"

if [ $TAG_POSTFIX ]; then
    IMAGE_TAG="${IMAGE_TAG}-$TAG_POSTFIX"
fi

BUILD_ARCH_LINE=""

if [ $BUILD_ARCH ]; then
    case $BUILDER in
        docker)
            BUILD_ARCH_LINE="--platform linux/${BUILD_ARCH}"
            ;;
        buildah)
            BUILD_ARCH_LINE="--arch ${BUILD_ARCH}"
            ;;
    esac

fi

# ------------------------------------------------------------------------------
# 'Main'

echo ""
echo "=== Session Configuration ================================================"
echo "    CACHE_DIR=${CACHE_DIR}"
echo "    JDK_MAJOR_VERSION=${JDK_MAJOR_VERSION}"
echo "    TOMCAT_VERSION=${TOMCAT_VERSION}"
echo "    BUILDER=${BUILDER}"
echo "    BUILD_ARCH=${BUILD_ARCH}"
echo ""


echo "=== Performing Sanity Checks ============================================"

checkFileExists "${TOMCAT_PKG_PATH}"
checkFileSignature "${TOMCAT_PKG_PATH}"


echo ""
echo "=== Perform Build ======================================================="
case $BUILDER in
    docker)
        docker build \
            --build-arg "JDK_MAJOR_VERSION=${JDK_MAJOR_VERSION}" \
            --build-arg "TOMCAT_VERSION=${TOMCAT_VERSION}" \
            $BUILD_ARCH_LINE \
            -t "$IMAGE_TAG" \
            -f "$DOCKER_FILE" .
        ;;
    buildah)
        buildah bud \
            --build-arg "JDK_MAJOR_VERSION=${JDK_MAJOR_VERSION}" \
            --build-arg "TOMCAT_VERSION=${TOMCAT_VERSION}" \
            $BUILD_ARCH_LINE \
            -t "$IMAGE_TAG" \
            -f "$DOCKER_FILE" .
        ;;
    *)
        echo "FAIL: Invalid builder ${BUILDER}."
        exit 1
        ;;
esac

echo "=== Build Complete ======================================================"
