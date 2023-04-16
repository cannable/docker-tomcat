#!/bin/bash

# ------------------------------------------------------------------------------
# Push Demo
# ------------------------------------------------------------------------------
# Demonstration of mass image pushing.
# This assumes you ran demo.sh and are horrified with how many images you have.

TCVER=9.0.73
REGISTRY=docker.io

if [[ $# -gt 1 ]]; then
    echo Pushes images.
    echo demo_push.sh [registry]
    exit 1
fi

if [[ $# -eq 1 ]]; then
    REGISTRY=$1
fi

for JDKVER in 11 17; do
    for BASE in alpine ol9 almalinux9; do
        manifest="cannable/tomcat:${TCVER}-openjdk${JDKVER}-${BASE}"

        echo "-----------------------------------------------------------------"
        echo "Pushing manifest docker://${REGISTRY}/${manifest}"
        buildah manifest push --all -f v2s2 "${manifest}" "docker://${REGISTRY}/${manifest}"
    done
done
