# docker-tomcat

What it says on the can - Apache Tomcat, but with a few hardening bits here and
there. Log4j too (if you don't build it out).

Most of this doc will outline key things to note about this container image, in
a haphazard sort of way.

# Obtaining

The easiest way is to pull one of the major version tags. NOTE: There's no
latest tag and these tags only apply to major versions, so, ex. 8 is actually
Tomcat 8.5 and not 8.0 (which is the convention Apache uses for organising the
downloads site).

# setenv.sh

This is actually installed to conf and symlinked to the bin directory. The
reason for this is to use a Docker volume to make configuration persistent
without requiring an extra volume mount.

# Log4j2

Installation mostly follows the guidance from Apache's Logging group. The three
log4j2 jar archives needed to handle Tomcat logging are installed to
/opt/tomcat/log4j2/lib. A config file mimicking the default Tomcat logging
config (but with 100 day rotation) is installed to /opt/tomcat/conf and
symlinked to /opt/tomcat/log4j2/conf, just like setenv.sh. The CLASSPATH is
extended to include these directories. JULI is still there, but nerfed (deleted
logging.properties).

# Run-Time Environment Variables

## CATALINA_HOME

What you'd expect. You shouldn't change this.

## TC_USER

Sets the user and group name of the user that runs Tomcat.

## TC_UID

Sets the user and group ID of the user that runs Tomcat.

# Building

The primary reason for retooling this project was to swap out the build scripts
with something more readily usable than the previous scripts. I'm still not
happy with them, but they work. Consider current state a temporary mess until I
have some time and desire to clean up said mess.

build_everything.sh is probably what you want to run. It will create a cache
directory to store various blobs (ex. Tomcat tar archives, signature files,
etc.) and verify signatures before running the builds.

There are some other scripts you can peruse, but they're mostly there for me to
shotgun a bunch of images and manifests to the Docker Hub.

## Build-Time Environment Variables

These are environment variables defined in _build_en.sh.

### ARCHES

This is an array of architectures for which to build container images. The build
scripts use buildah. You should set up binfmt_misc so you can make multiarch
images.

### TC_VERSIONS

This is another array containing Tomcat versions for which to build a container
image.

Builds were tested with 8.5, 9.0, and 10.0. Older versions will probably work,
though the download pass may not work quite right. If that occurs, try
downloading the tar archive and signature manually and putting it into ./cache.

### JDK_MAJOR_VERSION

This specifies the version of the OpenJDK to install, via Alpine's package
repos. I could have made this an array too, but the scripts were getting plenty
complicated as it was.

### LOG4J2_ENABLED

If you set this to 0, the build scripts will skip the Log4j bits.

### LOG4J2_VERSION

Version of Log4j to bundle.

# Why

I figured I'd leave this comment at the end because no one will or should care.
Why did I create this? I was bored. I wanted to experiment with Docker and chose
to mess with something I deal with on a daily basis. This was my first kick at
the can, Docker-wise and, after I got the initial implementation to work, I
didn't really have any plans on maintaining it.

I have since made some revisions. Why? My design sucked. Seriously. I threw
something together in a few hours that worked for a few different versions of
Tomcat and two different userlands (Alpine and Debian), but it was crap. I got
autobuilds working, but used a ton of copying and pasting in places. That's not
the way I typically roll, and the garbage-tier quality of it all bothered me.

Unfortunately, as this is just a hobby of mine, life, uh... found a way to get
in the way. The scripts are not in a state where I'm happy with them. I've got
some ideas, but I'm probably just going to make something more generic and
outside of this project.
