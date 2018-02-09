#!/bin/sh

overrides=/data/overrides
webapps=$CATALINA_HOME/webapps


# Install prereqs
echo Installing prerequisite packages...
apk update
apk add --no-cache dumb-init

echo Purging apk cache...
apk cache clean


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
addgroup -g $TC_UID $TC_USER
adduser -u $TC_UID -G $TC_USER -S -s /usr/sbin/nologin $TC_USER
chown -R $TC_USER $CATALINA_HOME
chgrp -R $TC_USER $CATALINA_HOME

