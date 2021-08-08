# setenv.sh

# Wait... shouldn't this be in bin? Yes.
# This is sitting in conf and is symlinked to bin so that it can live with the
# rest of the conf files in a docker volume and persist.

export CATALINA_OPTS="-Djdk.tls.ephemeralDHKeySize=2048"
