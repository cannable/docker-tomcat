# docker-tomcat

This provides Tomcat plus some simple/dumb scripting to help automate some
common tasks. Oh, and dumb-init is being used.

# Changing Run-Time Configuration

You can change these settings at run time.

**ENV_TC_USER**

Sets the user and group name of the user that runs Tomcat.

**ENV_TC_UID**

Sets the user and group ID of the user that runs Tomcat.

# Changing Build-Time Configuration

There are two things in the config file to care about:

**FROM**

You'll notice a bunch of different directories in the git tree - these
correspond with the Docker tags. Currently, there are only two sets of config
files, one for 'micro' builds that are based on Alpine, and 'mega' builds that
are built on Debian. The micro config deviates from the mega one, only in the
build.sh file (it uses apk instead of apt to do stuff, and has commands
tailored for BusyBox. At some point, I'll probably fix this.

Having said all that, if you need a combo that isn't built, just copy the
directory and tweak the FROM line in the Docker file.

**EXPOSE 8080/tcp**

Change this to match your Tomcat config.

**File Overrides**

Any files/directories created under this directory will be merged into the
Tomcat root directory, replacing the originals. Good candidates include config
files or any webapps you want deployed immediately.

An example setenv.sh is located at overrides/bin/setenv.sh.

# Build-Time Automation

Alter data/build.sh. This script deletes all default webapps except the
manager, then replaces files with overrides.

# Changing Run-Time Config

Alter data/init.sh. Out of the box, this just starts Tomcat as a non-root user.

