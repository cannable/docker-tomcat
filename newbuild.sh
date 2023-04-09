#!/bin/bash

CACHE_DIR="./cache"
JDK_MAJOR_VERSION=11
TOMCAT_VERSION=8.5.87


TOMCAT_PKG_PATH="./cache/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

# TODO: Check Tomcat hash

if [ ! -f $TOMCAT_PKG_PATH ]; then
    echo "${TOMCAT_PKG_PATH} does not exist!"
    exit 1
fi

buildah bud \
    --build-arg "JDK_MAJOR_VERSION=${JDK_MAJOR_VERSION}" \
    --build-arg "TOMCAT_VERSION=${TOMCAT_VERSION}" \
    -t "cannable/tomcat:${TOMCAT_VERSION}-openjdk${JDK_MAJOR_VERSION}" \
    -f ./Dockerfile .