#!/bin/sh

# ------------------------------------------------------------------------------
# Tomcat - Alpine Linux Build Script
# ------------------------------------------------------------------------------

ver=$TC_VERSION

# Generate URLs
major_ver=$(echo $ver | awk -F . -e '{print $1}')
url_keys="https://downloads.apache.org/tomcat/tomcat-${major_ver}/KEYS"

pkgname="apache-tomcat-${ver}"
filename="apache-tomcat-${ver}.tar.gz"

url_bin="https://archive.apache.org/dist/tomcat/tomcat-${major_ver}/v${ver}/bin/${filename}"
url_sig="${url_bin}.asc"

dirname=apache-log4j-${ver}-bin
destdir="$CATALINA_HOME/log4j2"

cd /tmp


# Grab the log4j PGP keys
echo Importing the Apache Logging PGP KEYS...
wget -O - ${url_keys} | gpg --import -


# Get the bits
echo Downloading tarball and signature...

if [ ! -f "/tmp/${filename}" ]; then
    echo Downloading ${url_bin}...
    wget "${url_bin}"
fi

if [ ! -f "/tmp/${filename}.asc" ]; then
    echo Downloading ${url_sig}...
    wget "${url_sig}"
fi


# Check the download signature
echo Checking tarball signature...
gpg --verify "${filename}.asc"

if [[ $? -ne 0 ]]; then
    (>&2 echo --------------------------------------------------)
    (>&2 echo --------------------------------------------------)
    (>&2 echo URGENT: $filename DOES NOT MATCH PGP SIGNATURE!)
    (>&2 echo IT WAS DOWNLOADED FROM ${url_bin}.)
    (>&2 echo THIS IS NOT PARTICULARLY GOOD. CHECK YOUR DOWNLOAD.)
    (>&2 echo BUILD PROCESS TERMINATED. CONTAINER WILL NOT FUNCTION.)
    (>&2 echo --------------------------------------------------)
    (>&2 echo --------------------------------------------------)
    exit 1
fi


echo Tarball passed PGP signature check.

# Extraction of the files is indirect, as we're working around limitations in
# busybox's implementation of tar

echo Installing Tomcat...
tar -xzf "${filename}" -C /tmp/
mv "/tmp/${pkgname}/" "${CATALINA_HOME}"


# Cleanup
echo Cleaning up staging area...
rm -f \
    "/tmp/${filename}" \
    "/tmp/${filename}.asc"

echo Installed Tomcat.
