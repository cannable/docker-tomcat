#!/bin/sh

# ------------------------------------------------------------------------------
# Tomcat - Alpine Linux Build Script
# ------------------------------------------------------------------------------

overrides=/data/overrides
webapps="${CATALINA_HOME}/webapps"


# Prune default webapps
echo Pruning default webapps...
rm -rf "${webapps}/docs"
rm -rf "${webapps}/examples"
rm -rf "${webapps}/host-manager"
rm -rf "${webapps}/ROOT"
#rm -rf "${webapps}/manager"


# Apply build-time file overrides
echo Applying build-time file overrides...
cp -R "${overrides}/*" "${CATALINA_HOME}"
rm -rf "${overrides}"
