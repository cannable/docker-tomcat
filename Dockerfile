FROM alpine


ARG JDK_MAJOR_VERSION=11
ARG TOMCAT_VERSION=8.5.87

ARG TOMCAT_PKG_NAME="apache-tomcat-${TOMCAT_VERSION}"

ENV CATALINA_HOME=/opt/tomcat \
        NAME=TOMCAT \
        JVM_MAXHEAP=1024m \
        TC_USER="tomcat" \
        TC_UID="1000"


COPY "./cache/${TOMCAT_PKG_NAME}.tar.gz" "/tmp/${TOMCAT_PKG_NAME}.tar.gz"

RUN apk add --no-cache \
        dumb-init \
        "openjdk${JDK_MAJOR_VERSION}-jre-headless" && \
        tar -xzf "/tmp/${TOMCAT_PKG_NAME}.tar.gz" -C /tmp/ && \
        mv "/tmp/${TOMCAT_PKG_NAME}" "${CATALINA_HOME}" && \
        rm -f "/tmp/${TOMCAT_PKG_NAME}.tar.gz" && \
        rm -rf "${webapps}/docs" && \
        rm -rf "${webapps}/examples" && \
        rm -rf "${webapps}/host-manager" && \
        rm -rf "${webapps}/ROOT"

COPY data/setenv.sh "${CATALINA_HOME}/bin/setenv.sh"
COPY data/init.sh "${CATALINA_HOME}/bin/init.sh"


EXPOSE "8080/tcp" \
       "8443/tcp"

#VOLUME ["/opt/tomcat/webapps", \
#        "/opt/tomcat/work"]

WORKDIR "${CATALINA_HOME}"
ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD [ "/bin/sh", "/init.sh" ]
