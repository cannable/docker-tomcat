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
    echo "    -h        Print this help."
    echo "    -c path   Set the artifact cache directory."
    echo "              Defaults to ${DEFAULT_CACHE_DIR}"
    echo "    -t ver    Set Tomcat version to build."
    echo "              Defaults to ${DEFAULT_TOMCAT_VERSION}"
    echo ""
}

# ------------------------------------------------------------------------------
# Handle command line arguments

CACHE_DIR="${DEFAULT_CACHE_DIR}"
TOMCAT_VERSION="${DEFAULT_TOMCAT_VERSION}"

while getopts "c:ht:" opt; do
    case $opt in
        c)
            CACHE_DIR="${OPTARG}"
            ;;
        h)
            printUsage
            exit
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
curl -o "${CACHE_DIR}/${TOMCAT_FILENAME}" "${TOMCAT_URL}"
curl -o "${CACHE_DIR}/${TOMCAT_FILENAME}.asc" "${TOMCAT_URL}.asc"

echo ""
echo "Operation Complete."