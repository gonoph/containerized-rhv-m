#!/bin/sh

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
