#!/bin/sh

# ------------------------------------------------------------------------------
# Tomcat - Alpine Linux Build Script
# ------------------------------------------------------------------------------

# Install prereqs
echo Installing prerequisite packages...
apk update
apk add --no-cache \
    dumb-init \
    gnupg \
    "openjdk${JDK_MAJOR_VERSION}-jre-headless"

echo Purging apk cache...
echo Ignore any cache error below this line.
apk cache clean

exit 0