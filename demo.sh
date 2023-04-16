#!/bin/bash

# ------------------------------------------------------------------------------
# Build Demo
# ------------------------------------------------------------------------------
# Demonstration of the Build process.

TCVER=9.0.73
JDKVER=11

./download.sh -t "$TCVER"
./build.sh -t "$TCVER" -j "$JDKVER"

./build.sh -t "$TCVER" -j "$JDKVER" -f ./Dockerfile.almalinux9 -p almalinux9
./build.sh -t "$TCVER" -j "$JDKVER" -f ./Dockerfile.ol9 -p ol9
