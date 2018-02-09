# docker-tomcat

This provides Tomcat plus some simple/dumb scripting to help automate some
common tasks.

# Changing Build-Time Configuration

There are four things in the config file to care about:

## FROM

Out of the box, this will build around Tomcat 9/JRE 8, though Tomcat 8 works,
and 7 should. Change this to suit your needs.

## ENV_TC_USER

Sets the user and group name of the user that runs Tomcat.

## ENV_TC_UID

Sets the user and group ID of the user that runs Tomcat.

## EXPOSE 8080/tcp

Change this to match your Tomcat config.

## File Overrides

Any files/directories created under this directory will be merged into the
Tomcat root directory, replacing the originals. Good candidates include config
files or any webapps you want deployed immediately.

An example setenv.sh is located at overrides/bin/setenv.sh.

# Build-Time Automation

Alter data/build.sh. This script deletes all default webapps except the
manager, replaces files with overrides, and creates a user for Tomcat.

# Changing Run-Time Config

Alter data/init.sh. Out of the box, this just starts Tomcat as a non-root user.

