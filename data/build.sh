#!/bin/sh

overrides=/data/overrides
webapps=$CATALINA_HOME/webapps


# Install prereqs
echo Installing prerequisite packages...
apt-get update
apt-get -y install dumb-init

echo Purging apt cache...
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


# Set up user
echo Setting up user...
groupadd -g $TC_UID $TC_USER
useradd -u $TC_UID -g $TC_USER -m $TC_USER -s /usr/sbin/nologin
chown -R $TC_USER $CATALINA_HOME
chgrp -R $TC_USER $CATALINA_HOME

