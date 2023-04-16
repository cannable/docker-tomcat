# ******************************************************************************
# Alpine Tomcat Container Image
# ******************************************************************************

FROM alpine

# JDK_MAJOR_VERSION
#
#   Specifies the major version of OpenJDK to install
#
ARG JDK_MAJOR_VERSION=11


# TOMCAT_VERSION
#
#   Specifies the version of Tomcat that will be installed.
#   This is primarily used for tagging the image.
#
ARG TOMCAT_VERSION=9.0.73

# TOMCAT_PKG_NAME
#
#   File name, without suffix, containing Tomcat.
#   You probably don't want to change this.
#
ARG TOMCAT_PKG_NAME="apache-tomcat-${TOMCAT_VERSION}"


# CACHE_DIR
#
#   Location storing container build artifacts.
#   This is where the build script will save the Tomcat tar archive.
#
ARG CACHE_DIR="./cache"

# ------------------------------------------------------------------------------
# Build Image

ENV CATALINA_HOME=/opt/tomcat \
    NAME=TOMCAT \
    TC_USER="tomcat" \
    TC_UID="1000"


COPY "${CACHE_DIR}/${TOMCAT_PKG_NAME}.tar.gz" "/tmp/${TOMCAT_PKG_NAME}.tar.gz"

RUN apk add --no-cache \
    "openjdk${JDK_MAJOR_VERSION}-jre-headless" && \
    tar -xzf "/tmp/${TOMCAT_PKG_NAME}.tar.gz" -C /tmp/ && \
    mv "/tmp/${TOMCAT_PKG_NAME}" "${CATALINA_HOME}" && \
    rm -f "/tmp/${TOMCAT_PKG_NAME}.tar.gz" && \
    rm -rf "${webapps}/docs" && \
    rm -rf "${webapps}/examples" && \
    rm -rf "${webapps}/host-manager" && \
    rm -rf "${webapps}/ROOT"

COPY data/setenv.sh "${CATALINA_HOME}/bin/setenv.sh"
COPY --chown=root:root --chmod=0755 data/init.sh.alpine /bin/init.sh


# ------------------------------------------------------------------------------
# Finish Image

EXPOSE "8080/tcp" \
       "8443/tcp"

#VOLUME ["/opt/tomcat/webapps", \
#        "/opt/tomcat/work"]

WORKDIR "${CATALINA_HOME}"
CMD [ "/bin/sh", "/bin/init.sh" ]
