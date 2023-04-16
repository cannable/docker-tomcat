# docker-tomcat

What it says on the can - Apache Tomcat, but with a few hardening bits here and
there.

Most of this doc will outline key things to note about this container image, in
a haphazard sort of way.


# setenv.sh

You probably want to mount this as a volume. It's created in the image in the
customary path (under bin) containing `export
CATALINA_OPTS="-Djdk.tls.ephemeralDHKeySize=2048"`.

# Run-Time Environment Variables

## CATALINA_HOME

What you'd expect. You can but shouldn't change this because everything will
explode massively.

## TC_USER

Sets the user and group name of the user that runs Tomcat.

## TC_UID

Sets the user and group ID of the user that runs Tomcat.

# Building

You can build the Dockerfile(s) directly. Alternatively, check out `download.sh`
and `build.sh`.

## download.sh

This script grabs the Tomcat KEYS file, imports that into GnuPG's keyring, then
downloads Tomcat. You can run this with no arguments, but you shouldn't - the
default version of Tomcat is hard-coded for demonstration purposes. Minimally,
you should pass `-t version`. Check out `download.sh -h` for more details.

## build.sh

Where `download.sh` is meant to get you into a position to build a bunch of
container images, build helps do the heavy lifting. You can run this with no
arguments, but like `download.sh` you shouldn't. Minimally, you should pass `-t
version`. There are a bunch of knobs you can tune, so give `download.sh -h` a
try.

## demo_build.sh and demo_push.sh

Like the names imply, these demonstrate some automation on top of `download.sh` and `build.sh`.

## Build-Time Environment Variables

### JDK_MAJOR_VERSION

This specifies the version of the OpenJDK to install.

# Why

I figured I'd leave this comment at the end because no one will or should care.
Why did I create this? I was bored. I wanted to experiment with Docker and chose
to mess with something I deal with on a daily basis. This was my first kick at
the can, Docker-wise and, after I got the initial implementation to work, I
didn't really have any plans on maintaining it.

I have since made some revisions. Why? My design sucked. Then I disappeared for
2 years, came back, and saw it STILL SUCKED. Seriously? I've refactored it a
third time, pray I do not refactor it further.

I should point out this is a hobby project, so if you like what I'm doing with
these, don't use the images on the Docker Hub because they're likely out of
date. Cloning the git repo and building the images yourself would be safer and
will give you more freedom to customize the build process as you like.
