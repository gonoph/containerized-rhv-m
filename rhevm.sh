#!/bin/sh
# Copyright 2017 Billy Holmes
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

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
