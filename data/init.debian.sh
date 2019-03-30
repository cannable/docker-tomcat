#!/bin/sh

# ------------------------------------------------------------------------------
# Tomcat Init Script (Debian)
# ------------------------------------------------------------------------------

# Set up user
echo Setting up user...
groupadd -g $TC_UID $TC_USER
useradd -u $TC_UID -g $TC_USER -m $TC_USER -s /usr/sbin/nologin
chown -R $TC_USER:$TC_USER $CATALINA_HOME

# Start Tomcat
echo Starting Tomcat...

su -p -l -s /bin/sh -c "/bin/sh $CATALINA_HOME/bin/catalina.sh run" $TC_USER
