#!/bin/bash

# ------------------------------------------------------------------------------
# Build Demo
# ------------------------------------------------------------------------------
# Demonstration of piling automation on top of the build script.
# This explicitly uses Buildah, just for kicks.

TCVER=9.0.73

./download.sh -t "$TCVER"

# Build a whole bunch of images
for ARCH in arm64 amd64; do
    for JDKVER in 11 17; do
        ./build.sh -b -a "$ARCH" -t "$TCVER" -j "$JDKVER" -p alpine
        ./build.sh -b -a "$ARCH" -t "$TCVER" -j "$JDKVER" -f ./Dockerfile.almalinux9 -p almalinux9
        ./build.sh -b -a "$ARCH" -t "$TCVER" -j "$JDKVER" -f ./Dockerfile.ol9 -p ol9
    done
done

# Create some manifest spaghetti

for JDKVER in 11 17; do
    for BASE in alpine ol9 almalinux9; do
        manifest="cannable/tomcat:${TCVER}-openjdk${JDKVER}-${BASE}"
        buildah manifest create "$manifest"

        for ARCH in amd64 arm64; do
            buildah manifest add "$manifest" "${manifest}-${ARCH}"
        done
    done
done