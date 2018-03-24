#!/bin/sh

# ------------------------------------------------------------------------------
# Tomcat - Debian Build Script
# ------------------------------------------------------------------------------

overrides=/data/overrides
webapps=$CATALINA_HOME/webapps


# Install prereqs
echo Installing prerequisite packages...
apt-get update
apt-get -y install dumb-init

echo Purging apt cache...
echo Ignore any cache error below this line.
apt-get -y clean
rm -rf /var/lib/apt/lists/*


# Prune default webapps
echo Pruning default webapps...
rm -rf $webapps/docs
rm -rf $webapps/examples
rm -rf $webapps/host-manager
rm -rf $webapps/ROOT
#rm -rf $webapps/manager


# Apply file overrides
echo Applying file overrides...
cp -R $overrides/* $CATALINA_HOME
rm -rf $overrides
