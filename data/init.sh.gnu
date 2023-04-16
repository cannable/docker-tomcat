#!/bin/bash

# ------------------------------------------------------------------------------
# Tomcat Init Script (GNU Userland)
# ------------------------------------------------------------------------------


# Set up user
groupadd -g "${TC_UID}" "${TC_USER}"

useradd \
    -u "${TC_UID}" \
    -g "${TC_UID}" \
    -G "${TC_USER}" \
    -s /bin/false \
    "${TC_USER}"

chown -R "${TC_USER}:${TC_USER}" "${CATALINA_HOME}"


# Start Tomcat
su -p -l -s /bin/sh -c "/bin/sh $CATALINA_HOME/bin/catalina.sh run" "${TC_USER}"
