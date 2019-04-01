# docker-tomcat

This provides Tomcat plus some simple/dumb scripting to help automate some
common tasks. Oh, and dumb-init is being used.

# The Various Tags

The first part of the tag specifies the version of Tomcat and is required.
There are 'micro' and 'macro' versions. The micro versions are based on Alpine,
while the macro versions are based on Debian (these choices are based entirely
on what Apache builds... I'm lazy that way).

There are a few -log4j2 tags, as well. In these containers, log4j2 handles
logging for Tomcat. JULI is still there, but nerfed. A log4j2-tomcat.xml file
is dropped that approximates the same functionality as the stock
logging.properties (there is one minor tweak - log files are rotated daily and
pruned after 100 days).

# Changing Run-Time Configuration

You can change these settings at run time.

**ENV_TC_USER**

Sets the user and group name of the user that runs Tomcat.

**ENV_TC_UID**

Sets the user and group ID of the user that runs Tomcat.

# Changing Build-Time Configuration

There are two things in the config file to care about:

**FROM**

You can change this via the tcorigin build argument.

**EXPOSE 8443/tcp, EXPOSE 8080/tcp**

Change this to match your Tomcat config.

**LOG4J2_VERSION**

This only applies to Log4j2 Dockerfiles. The version specified here will be
installed by log4j2.sh. Change this to suit your requirements.

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

# Why

I figured I'd leave this comment at the end because no one will or should care.
Why did I create this? I was bored. I wanted to experiment with Docker and
chose to mess with something I deal with on a daily basis. This was my first
kick at the can, Docker-wise and, after I got the initial implementation to
work, I didn't really have any plans on maintaining it.

I have since made some revisions. Why? My design sucked. Seriously. I threw
something together in a few hours that worked for a few different versions of
Tomcat and two different userlands (Alpine and Debian), but it was crap. I got
autobuilds working, but used a ton of copying and pasting in places. That's not
the way I typically roll, and the garbage-tier quality of it all bothered me.

Unfortunately, as this is just a hobby of mine, life, uh... found a way to get
in the way. I've spent months wanting to circle back and fix this (the server
admin in me just gagged a bit because I used "circle back" in a sentence
without batting an eyelash). I finally found some time to dedicate to fixing
this mess.

After finally fixing the directory structure stuff (which was pretty trivial,
tbh), I was left asking "what next?" Well, let's experiment. Let's do volumes,
as I really should have done that to start with. Done. Next... Ummmm....
Log4j2, that's a good one. Let's do that. Okay, done. Now what?

That is, ultimately, what this project is - somewhere for me to experiment with
Docker and Tomcat stuff. If anyone ever uses this in production (I might fork
it internally sometime, actually), feel free to drop me a line, and I'm sorry
btw.
