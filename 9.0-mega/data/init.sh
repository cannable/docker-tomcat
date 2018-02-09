#!/bin/sh

su -p -l -s /bin/sh -c "/bin/sh $CATALINA_HOME/bin/catalina.sh run" $TC_USER
