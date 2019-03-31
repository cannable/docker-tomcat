#!/bin/bash

ver=2.11.2
filename=apache-log4j-${ver}-bin.tar.gz
dirname=apache-log4j-${ver}-bin
url_keys=https://www.apache.org/dist/logging/KEYS
url_bin=https://mirror.csclub.uwaterloo.ca/apache/logging/log4j/${ver}
url_sig=https://www.apache.org/dist/logging/log4j/${ver}
destdir="$CATALINA_HOME/log4j2"


cd /data/log4j2/

apk add --no-cache gnupg

# Grab the log4j PGP keys
wget -O - ${url_keys} | gpg --import -


# Get the bits
wget "${url_bin}/${filename}"
wget "${url_sig}/${filename}.asc"


# Check the download signature
#check=$(gpg --status-fd 1 --verify "${filename}.asc")
gpg --verify "${filename}.asc"

if [[ $? -ne 0 ]]; then
    (>&2 echo --------------------------------------------------)
    (>&2 echo --------------------------------------------------)
    (>&2 echo URGENT: $filename DOES NOT MATCH PGP SIGNATURE!)
    (>&2 echo IT WAS DOWNLOADED FROM ${url_bin}/${filename}.)
    (>&2 echo THIS IS NOT PARTICULARLY GOOD. CHECK YOUR DOWNLOAD.)
    (>&2 echo BUILD PROCESS TERMINATED. CONTAINER WILL NOT FUNCTION.)
    (>&2 echo --------------------------------------------------)
    (>&2 echo --------------------------------------------------)
    exit 1
fi

echo Tarball passed PGP signature check.

# Extraction of the files is indirect, as we're working around limitations in
# busybox's implementation of tar

tar -xf "${filename}" -C . \
    "${dirname}/log4j-api-${ver}.jar" \
    "${dirname}/log4j-core-${ver}.jar" \
    "${dirname}/log4j-appserver-${ver}.jar"

mkdir -p "$destdir/lib" "$destdir/conf"

cp \
    "${dirname}/log4j-api-${ver}.jar" \
    "${dirname}/log4j-core-${ver}.jar" \
    "${dirname}/log4j-appserver-${ver}.jar" \
    "$destdir/lib"

cp setenv.sh "$CATALINA_HOME/bin"
cp log4j2-tomcat.xml "$CATALINA_HOME/conf"
ln -s "$CATALINA_HOME/conf/log4j2-tomcat.xml" "$destdir/conf/log4j2-tomcat.xml"
rm "$CATALINA_HOME/conf/logging.properties"


# Cleanup

cd /data
rm -rf ./log4j2

echo Purging apk cache...
echo Ignore any cache error below this line.
apk cache clean

echo Completed installing log4j2.
