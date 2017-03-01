# containerized-rhv-m
Containerized version of Red Hat Virtualization Manager
So, I got some interest for this, so I figured I'd detail what I did to make it work.

# Overview
========

I installed RHV on another box using a remote postgresql. This was the easiest
path as that means I didn't need to wrangle our RHEL7 docker image to run
systemd - which *IS* possible, but it's painful and needs `CAP_SYS_ADMIN` and a
read only mount of /sys/fs/cgroup - and of course that recipe changes a bit
when you use newer versions of our docker as we've made it slightly easier to
run systemd in docker.

But, with the scenario I used, you don't need to do all that.

Edit the hostname and other settings to your environment...

## STEPS

1. Install RHV-M on or physical or VM box (libvirt or virtualbox - doesn't matter, you'll delete it later)

2. setup RHV-M to your liking.
  1. use your own apache cert signed by your own CA if you want
  2. MUST make sure you select **remote DB** for engine and dwh.
  3. SAVE the answer file somewhere and rename it **answer.txt**

3. backup it up: `engine-backup  --mode=backup --file=/root/backup.tgz --log=/tmp/log.txt  --scope=files`
  1. save the **backup.tgz** somewhere

4. on your docker build host, subscribe to the right entitlements to gain access to RHV.
  1. in my home lab, I have a pulp mirror of all those repos, so I just put some repo files in the container file system that point to my mirror and use that.
  2. obviously, that doesn't work in your environment, so the Dockerfile is a modified version of what I use in my lab.

5. build the docker image
  1. remember to place the **backup.tgz and answer.txt** in the same place as the Dockerfile so it can find it

6. push the docker image to your internal registry
  1. you have an internal registry, right??

7. load the yaml files to build the replication controller and service so it will deploy the pod that contains the (4) containers needed to run RHV-M.

8. edit your haproxy or load balancer to point to the new service end point in your kube cluster

9. edit your DNS to point the hostname to your haproxy / load balancer

10. delete/repurpose the original RHV VM or physical machine you used to create the backup.

## Loading the yaml files

You will need a kubernetes cluster or Openshift Container Platform.

### The ReplicationController

This defines (4) containers:

1. httpd - the apache process
2. engine - the API engine
3. engine-dwh - the metric collection engine
4. websocket - then websocket process to handle callbacks from the web UI

```shell
kubectl create -f rhevm.rc.yaml
```

### The Service

This exposes the container's ports as a service to the cluster. You will need to further expose this via your own **haproxy** or via a kubernetes / OCP **router** by defining your own **route**.

```shell
kubectl create -f rhevm.service.yaml
```

License
-------

GPLv3

Author Information
------------------

Billy Holmes <billy@gonoph.net>
