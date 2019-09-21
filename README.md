# kubernetes-vagrant-debian-cluster

This kubernetes cluster is composed of 1 master and 5 nodes debian jessie64.

## The main script:

```console
$ bin/platform-control.sh

Kubernetes Vagrant Debian Cluster Platform Control Script

Options:
 - destroy: destroy and remove all vms
 - restart: vms reboot
 - status: current vms and kubectl status
 - up: platform up :)
```

### Example: bin/platform-control.sh up

```console
$ bin/platform-control.sh up

Kubernetes Vagrant Debian Cluster Platform Control Script

Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'node-1' up with 'virtualbox' provider...
Bringing machine 'node-2' up with 'virtualbox' provider...
Bringing machine 'node-3' up with 'virtualbox' provider...
Bringing machine 'node-4' up with 'virtualbox' provider...
Bringing machine 'node-5' up with 'virtualbox' provider...

[...]

NAME         STATUS     ROLES    AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                      KERNEL-VERSION   CONTAINER-RUNTIME
k8s-master   NotReady   master   3m20s   v1.16.0   192.168.10.10   <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-1   NotReady   <none>   2m42s   v1.16.0   <none>          <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-2   NotReady   <none>   2m36s   v1.16.0   <none>          <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-3   NotReady   <none>   2m17s   v1.16.0   <none>          <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-4   NotReady   <none>   118s    v1.16.0   <none>          <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-5   NotReady   <none>   98s     v1.16.0   <none>          <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
```

Enjoy!!