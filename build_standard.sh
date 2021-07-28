#!/bin/sh

if [[ $# -ne 2 ]]; then
  echo $0 branch version
  echo Example: $0 micro 8.5
  exit 1
fi
branch=$1
tcver=$2

docker build --build-arg "TC_VERSION=micro" -t "cannable/tomcat:${tcver}-micro" -f "./Dockerfile" .
