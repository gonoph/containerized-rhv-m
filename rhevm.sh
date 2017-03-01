#!/bin/sh

: ${IMAGE:=my-local-registry.example.com/rhel7/rhevm:4.0-0}
: ${NAME:=rhevm}
: ${CONTAINER_HOSTNAME:=$(grep OVESETUP_CONFIG/fqdn answers.txt  | cut -d: -f 2)}
: ${EXPOSE:=-p 80:80 -p 443:443}
: ${RM:=yes}

case $RM in
  yes|y|Y|Yes|YES|1|True|true)
    RM="--rm"
    ;;
  *) RM=""
    ;;
esac

[ "x$NAME" != "x" ] && NAME="--name=$NAME"

if [ $# -eq 0 ] ; then
  cat << DOCS
Issue a command as an argument, or an alias to invoke a command.

Aliases:

httpd		the apache server that will answer web requests on port 80 and 443.
engine		the engine process that interfaces with the RHV hosts and provides the API.
engine-dwh	the DWH engine proceess that collects metrics on running VMs and hosts.
websocket	the websocket component that provides a better UI.

or give a command:

/bin/bash

DOCS
  exit 1
fi

echo Running: exec docker run -it --hostname=$CONTAINER_HOSTNAME $NAME $EXPOSE $RM $IMAGE "$@"
exec docker run -it --hostname=$CONTAINER_HOSTNAME $NAME $EXPOSE $RM $IMAGE "$@"
