#!/bin/bash

# ------------------------------------------------------------------------------
# Tomcat Init Script (Alpine Linux)
# ------------------------------------------------------------------------------


# Set up user
addgroup -g "${TC_UID}" "${TC_USER}"

adduser \
    -u "${TC_UID}" \
    -G "${TC_USER}" \
    -s /usr/sbin/nologin \
    -S "${TC_USER}"

chown -R "${TC_USER}:${TC_USER}" "${CATALINA_HOME}"


# Start Tomcat
su -p -l -s /bin/sh -c "/bin/sh $CATALINA_HOME/bin/catalina.sh run" "${TC_USER}"
