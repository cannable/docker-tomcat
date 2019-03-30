#!/bin/sh

# ------------------------------------------------------------------------------
# Tomcat - Alpine Linux Build Script
# ------------------------------------------------------------------------------

overrides=/data/overrides
webapps=$CATALINA_HOME/webapps
echo "shell: $SHELL"

# Userland detection
if [[ -x $(which apk) ]]; then
    ostype=alpine
elif [[ -x $(which apt-get) ]]; then
    ostype=debian
else
    echo 'Unknown userland.'
    exit 1
fi

echo "Userland: $ostype"


case "$ostype" in

    alpine)
        # Install prereqs
        echo Installing prerequisite packages...
        apk update
        apk add --no-cache dumb-init

        echo Purging apk cache...
        echo Ignore any cache error below this line.
        apk cache clean
        ;;

    debian)

        # Install prereqs
        echo Installing prerequisite packages...
        apt-get update
        apt-get -y install dumb-init

        echo Purging apt cache...
        echo Ignore any cache error below this line.
        apt-get -y clean
        rm -rf /var/lib/apt/lists/*
        ;;
esac


# Prune default webapps
echo Pruning default webapps...
rm -rf $webapps/docs
rm -rf $webapps/examples
rm -rf $webapps/host-manager
rm -rf $webapps/ROOT
#rm -rf $webapps/manager


# Apply build-time file overrides
echo Applying build-time file overrides...
cp -R $overrides/* $CATALINA_HOME
rm -rf $overrides


# Choose Userland-specific init script
echo Configuring init.sh...
echo cp /data/init.${ostype}.sh /data/init.sh
cp "/data/init.${ostype}.sh" /data/init.sh
