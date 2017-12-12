FROM tomcat:8.0-jre8
ENV NAME HARDTC
ENV TC_USER tomcat
ENV TC_UID 6060
WORKDIR /usr/local/tomcat
COPY ["./data", "/data"]
COPY ["./overrides", "/data/overrides"]
RUN ["/bin/sh", "/data/build.sh"]
EXPOSE 8080/tcp
CMD ["/bin/sh", "/data/init.sh"]

