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

cmd=$1

case $cmd in
  httpd)
    shift 1
    exec /usr/sbin/httpd -e info -DFOREGROUND "$@"
    ;;
  engine)
    shift 1
    ulimit -n 65535
    exec chroot --userspec=ovirt:ovirt / /usr/share/ovirt-engine/services/ovirt-engine/ovirt-engine.py --redirect-output $EXTRA_ARGS "$@" start
    ;;
  engine-dwh)
    shift 1
    exec chroot --userspec=ovirt:ovirt / /usr/share/ovirt-engine-dwh/services/ovirt-engine-dwhd/ovirt-engine-dwhd.py --redirect-output $EXTRA_ARGS "$@" start
    ;;
  websocket)
    shift 1 
    ulimit -n 65535
    ulimit -u 2048
    exec chroot --userspec=ovirt:ovirt / /usr/share/ovirt-engine/services/ovirt-websocket-proxy/ovirt-websocket-proxy.py  $EXTRA_ARGS "$@" start
    ;;
esac

if [ "x$cmd" = "x" ] ; then
  exec /bin/bash
fi
exec "$@"
