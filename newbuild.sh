#!/bin/bash

# ------------------------------------------------------------------------------
# Build Container Image
# ------------------------------------------------------------------------------
# This script provides some scaffolding to make building multiple images at once
# easier.

# ------------------------------------------------------------------------------
# Defaults

DEFAULT_CACHE_DIR="./cache"
DEFAULT_JDK_MAJOR_VERSION=11
DEFAULT_TOMCAT_VERSION=9.0.73


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
    echo "    -j ver    Set OpenJDK major version to build."
    echo "              Defaults to ${DEFAULT_JDK_MAJOR_VERSION}"
    echo "    -t ver    Set Tomcat version to build."
    echo "              Defaults to ${DEFAULT_TOMCAT_VERSION}"
    echo ""
}

# checkFileExists -- Confirm a file exists.
checkFileExists() {
    if [ -z $1 ]; then
        echo "checkFileExists: no argument passed."
        exit 1
    fi

    if [ ! -f $1 ]; then
        echo "    FAIL: ${1} does not exist!"
        echo ""
        echo "Build terminated."
        exit 1
    fi
    echo "    ${1} exists."
}

# ------------------------------------------------------------------------------
# Handle command line arguments

CACHE_DIR="${DEFAULT_CACHE_DIR}"
JDK_MAJOR_VERSION="${DEFAULT_JDK_MAJOR_VERSION}"
TOMCAT_VERSION="${DEFAULT_TOMCAT_VERSION}"

while getopts "hc:t:j:" opt; do
    case $opt in
        h)
            printUsage
            exit
            ;;
        c)
            CACHE_DIR="${OPTARG}"
            ;;
        j)
            JDK_MAJOR_VERSION="${OPTARG}"
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


# ------------------------------------------------------------------------------
# 'Main'

echo ""
echo "Session configuration is:"
echo "    CACHE_DIR=${CACHE_DIR}"
echo "    JDK_MAJOR_VERSION=${JDK_MAJOR_VERSION}"
echo "    TOMCAT_VERSION=${TOMCAT_VERSION}"
echo ""


echo "Performing sanity checks."

checkFileExists "${TOMCAT_PKG_PATH}"
checkFileExists "${TOMCAT_PKG_PATH}.asc"

# TODO: Check Tomcat hash

buildah bud \
    --build-arg "JDK_MAJOR_VERSION=${JDK_MAJOR_VERSION}" \
    --build-arg "TOMCAT_VERSION=${TOMCAT_VERSION}" \
    -t "cannable/tomcat:${TOMCAT_VERSION}-openjdk${JDK_MAJOR_VERSION}" \
    -f ./Dockerfile .