#!/bin/bash

# ------------------------------------------------------------------------------
# Cache Manager
# ------------------------------------------------------------------------------
# This script downloads Tomcat archives and bootstraps PGP.

# ------------------------------------------------------------------------------
# Defaults

DEFAULT_CACHE_DIR="./cache"
DEFAULT_TOMCAT_VERSION=9.0.73
DEFAULT_FORCE=0
DEFAULT_KEYS_URL="https://downloads.apache.org/tomcat"
DEFAULT_MIRROR_URL="https://archive.apache.org/dist/tomcat"

# ------------------------------------------------------------------------------
# Function Definitions

# printUsage -- Print the customary help/usage blurb.
printUsage() {
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "    -c path   Set the artifact cache directory."
    echo "              Defaults to ${DEFAULT_CACHE_DIR}"
    echo "    -h        Print this help."
    echo "    -f        Overwrite any existing artifacts."
    echo "    -t ver    Set Tomcat version to build."
    echo "              Defaults to ${DEFAULT_TOMCAT_VERSION}"
    echo ""
}

# getFile -- Downloads artifact.
getFile() {
    if [ -z $1 -o -z $2 ]; then
        echo "getFile: argument issue."
        exit 1
    fi

    local url="$1"
    local outFile="$2"

    if [ ! -f $outFile -o $FORCE -ne 0 ]; then
        curl -o "$outFile" "$url"
    fi

}

# ------------------------------------------------------------------------------
# Handle command line arguments

CACHE_DIR="${DEFAULT_CACHE_DIR}"
TOMCAT_VERSION="${DEFAULT_TOMCAT_VERSION}"
FORCE="${DEFAULT_FORCE}"

while getopts "c:hft:" opt; do
    case $opt in
        c)
            CACHE_DIR="${OPTARG}"
            ;;
        h)
            printUsage
            exit
            ;;
        f)
            FORCE=1
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

TOMCAT_MAJOR_VERSION=$(grep -Po '^[^.]+' <<< $TOMCAT_VERSION)
TOMCAT_FILENAME="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
KEYS_URL="${DEFAULT_KEYS_URL}/tomcat-${TOMCAT_MAJOR_VERSION}/KEYS"
TOMCAT_URL="${DEFAULT_MIRROR_URL}/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/${TOMCAT_FILENAME}"


# ------------------------------------------------------------------------------
# 'Main'

echo ""
echo "Session configuration is:"
echo "    CACHE_DIR=${CACHE_DIR}"
echo "    TOMCAT_VERSION=${TOMCAT_VERSION}"
echo "    TOMCAT_MAJOR_VERSION=${TOMCAT_MAJOR_VERSION}"
echo "    KEYS_URL=${KEYS_URL}"
echo "    TOMCAT_URL=${TOMCAT_URL}"
echo ""

if [ ! -e $CACHE_DIR ]; then
    echo "Creating ${CACHE_DIR}."
    mkdir "$CACHE_DIR"
fi

if [ ! -d $CACHE_DIR ]; then
    echo "FAIL: ${CACHE_DIR} is not a directory."
    exit 1
fi

echo ""
echo "Caching artifacts."

echo ""
echo "Bootstrapping GnuPG."
curl "$KEYS_URL" | gpg --import -

echo ""
echo "Downloading Tomcat and signature file."

getFile "${TOMCAT_URL}" "${CACHE_DIR}/${TOMCAT_FILENAME}"
getFile "${TOMCAT_URL}.asc" "${CACHE_DIR}/${TOMCAT_FILENAME}.asc"
#curl -o "${CACHE_DIR}/${TOMCAT_FILENAME}" "${TOMCAT_URL}"
#curl -o "${CACHE_DIR}/${TOMCAT_FILENAME}.asc" "${TOMCAT_URL}.asc"

echo ""
echo "Operation Complete."