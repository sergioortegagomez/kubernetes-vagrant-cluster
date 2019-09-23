# kubernetes-vagrant-debian-cluster

This kubernetes cluster is composed of 1 master and 5 nodes debian jessie64.

## Requirements

- [Linux Ubuntu 18.04](https://ubuntu.com/)
- [Vagrant 2.0.2](https://www.vagrantup.com/)
- [VirtualBox 5.2.32](https://www.virtualbox.org/)

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

NAME         STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                      KERNEL-VERSION   CONTAINER-RUNTIME
k8s-master   Ready    master    1m   v1.16.0   192.168.10.10   <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-1   Ready    <none>    1m   v1.16.0   192.168.10.11   <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-2   Ready    <none>    1m   v1.16.0   192.168.10.12   <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-3   Ready    <none>    1m   v1.16.0   192.168.10.13   <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-4   Ready    <none>    1m   v1.16.0   192.168.10.14   <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3
k8s-node-5   Ready    <none>    1m   v1.16.0   192.168.10.15   <none>        Debian GNU/Linux 8 (jessie)   3.16.0-9-amd64   docker://18.6.3

Kubernetes master is running at https://192.168.10.10:6443
KubeDNS is running at https://192.168.10.10:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

Kubernetes-dashboard at: http://192.168.10.10:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/
```

Enjoy!!