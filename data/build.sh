#!/bin/sh

overrides=/data/overrides
webapps=$CATALINA_HOME/webapps


# Prune default webapps
rm -rf $webapps/docs
rm -rf $webapps/examples
rm -rf $webapps/host-manager
rm -rf $webapps/ROOT
#rm -rf $webapps/manager


# Apply file overrides
cp -R $overrides/* $CATALINA_HOME
rm -rf $overrides


# Set up user
groupadd -g $TC_UID $TC_USER
useradd -u $TC_UID -g $TC_USER -m $TC_USER -s /usr/sbin/nologin
chown -R $TC_USER $CATALINA_HOME
chgrp -R $TC_USER $CATALINA_HOME

