FROM alpine

ARG TC_VERSION=10.0.8
ARG JDK_MAJOR_VERSION=11

ENV NAME HARDTC
ENV TC_USER tomcat
ENV TC_UID 6060
ENV CATALINA_HOME /opt/tomcat

COPY ["./data", "/data"]
COPY ["./overrides", "/data/overrides"]
RUN ["/bin/sh", "/data/build.sh"]
RUN ["/bin/sh", "/data/build-tomcat.sh"]
RUN ["/bin/sh", "/data/build-cleanup.sh"]

VOLUME ["$CATALINA_HOME/conf", \
        "$CATALINA_HOME/logs", \
        "$CATALINA_HOME/temp", \
        "$CATALINA_HOME/webapps", \
        "$CATALINA_HOME/work"]

EXPOSE 8443/tcp
EXPOSE 8080/tcp

WORKDIR "$CATALINA_HOME"

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/bin/bash", "/data/init.sh"]