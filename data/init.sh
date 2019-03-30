#!/bin/sh

# ------------------------------------------------------------------------------
# Tomcat Init Script (Alpine Linux)
# ------------------------------------------------------------------------------

# Set up user
echo Setting up user...
addgroup -g $TC_UID $TC_USER
adduser -u $TC_UID -G $TC_USER -S -s /usr/sbin/nologin $TC_USER
chown -R $TC_USER:$TC_USER $CATALINA_HOME
#chgrp -R $TC_USER $CATALINA_HOME

# Start Tomcat
echo Starting Tomcat...
su -p -l -s /bin/sh -c "/bin/sh $CATALINA_HOME/bin/catalina.sh run" $TC_USER
