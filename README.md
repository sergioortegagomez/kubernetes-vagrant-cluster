# kubernetes-vagrant-cluster

This kubernetes cluster is composed of 1 master and 5 nodes.

## Requirements

- [Linux Ubuntu 18.04](https://ubuntu.com/)
- [Vagrant 2.0.2](https://www.vagrantup.com/)
- [VirtualBox 5.2.32](https://www.virtualbox.org/)

## The main script:

```console
$ bin/platform-control.sh

Kubernetes Vagrant Cluster Platform Control Script

Options:
 - destroy: destroy and remove all vms
 - restart: vms reboot
 - status: current vms and kubectl status
 - up: platform up :)
```

### Example: bin/platform-control.sh up

```console
$ bin/platform-control.sh up

Kubernetes Vagrant Cluster Platform Control Script

Bringing machine 'k8s-master' up with 'virtualbox' provider...
Bringing machine 'k8s-node-1' up with 'virtualbox' provider...
Bringing machine 'k8s-node-2' up with 'virtualbox' provider...
Bringing machine 'k8s-node-3' up with 'virtualbox' provider...
Bringing machine 'k8s-node-4' up with 'virtualbox' provider...
Bringing machine 'k8s-node-5' up with 'virtualbox' provider...

[...]

[ Nodes ]
NAME         STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
k8s-master   Ready    master   13m   v1.17.0   10.0.2.15       <none>        Ubuntu 16.04.6 LTS   4.4.0-170-generic   docker://19.3.5
k8s-node-1   Ready    <none>   13m   v1.17.0   192.168.50.11   <none>        Ubuntu 16.04.6 LTS   4.4.0-170-generic   docker://19.3.5
k8s-node-2   Ready    <none>   12m   v1.17.0   192.168.50.12   <none>        Ubuntu 16.04.6 LTS   4.4.0-170-generic   docker://19.3.5
k8s-node-3   Ready    <none>   12m   v1.17.0   192.168.50.13   <none>        Ubuntu 16.04.6 LTS   4.4.0-170-generic   docker://19.3.5
k8s-node-4   Ready    <none>   12m   v1.17.0   192.168.50.14   <none>        Ubuntu 16.04.6 LTS   4.4.0-170-generic   docker://19.3.5
k8s-node-5   Ready    <none>   12m   v1.17.0   192.168.50.15   <none>        Ubuntu 16.04.6 LTS   4.4.0-170-generic   docker://19.3.5
[ Pods ]
NAMESPACE              NAME                                         READY   STATUS    RESTARTS   AGE   IP              NODE         NOMINATED NODE   READINESS GATES
default                http-768f8fdbc-wm4xw                         1/1     Running   0          12m   10.32.0.2       k8s-node-2   <none>           <none>
kube-system            coredns-6955765f44-9ln2x                     1/1     Running   0          13m   10.32.0.3       k8s-master   <none>           <none>
kube-system            coredns-6955765f44-cvdf9                     1/1     Running   0          13m   10.32.0.2       k8s-master   <none>           <none>
kube-system            etcd-k8s-master                              1/1     Running   0          13m   10.0.2.15       k8s-master   <none>           <none>
kube-system            kube-apiserver-k8s-master                    1/1     Running   0          13m   10.0.2.15       k8s-master   <none>           <none>
kube-system            kube-controller-manager-k8s-master           1/1     Running   0          13m   10.0.2.15       k8s-master   <none>           <none>
kube-system            kube-proxy-6br84                             1/1     Running   0          13m   192.168.50.11   k8s-node-1   <none>           <none>
kube-system            kube-proxy-6gbpq                             1/1     Running   0          12m   192.168.50.12   k8s-node-2   <none>           <none>
kube-system            kube-proxy-9sm6w                             1/1     Running   0          12m   192.168.50.14   k8s-node-4   <none>           <none>
kube-system            kube-proxy-cjsjv                             1/1     Running   0          13m   10.0.2.15       k8s-master   <none>           <none>
kube-system            kube-proxy-nqz69                             1/1     Running   0          12m   192.168.50.15   k8s-node-5   <none>           <none>
kube-system            kube-proxy-whchl                             1/1     Running   0          12m   192.168.50.13   k8s-node-3   <none>           <none>
kube-system            kube-scheduler-k8s-master                    1/1     Running   0          13m   10.0.2.15       k8s-master   <none>           <none>
kube-system            weave-net-cwxzc                              2/2     Running   1          12m   192.168.50.14   k8s-node-4   <none>           <none>
kube-system            weave-net-d52b9                              2/2     Running   1          12m   192.168.50.12   k8s-node-2   <none>           <none>
kube-system            weave-net-j296r                              2/2     Running   1          13m   192.168.50.11   k8s-node-1   <none>           <none>
kube-system            weave-net-q2k4s                              2/2     Running   1          12m   192.168.50.13   k8s-node-3   <none>           <none>
kube-system            weave-net-qmbjn                              2/2     Running   1          12m   192.168.50.15   k8s-node-5   <none>           <none>
kube-system            weave-net-smmbj                              2/2     Running   0          13m   10.0.2.15       k8s-master   <none>           <none>
kubernetes-dashboard   dashboard-metrics-scraper-76585494d8-m4xfj   1/1     Running   0          12m   10.32.0.5       k8s-master   <none>           <none>
kubernetes-dashboard   kubernetes-dashboard-5996555fd8-lr6mx        1/1     Running   0          12m   10.32.0.4       k8s-master   <none>           <none>
[ Services ]
NAMESPACE              NAME                        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                  AGE   SELECTOR
default                kubernetes                  ClusterIP   10.96.0.1       <none>        443/TCP                  13m   <none>
kube-system            kube-dns                    ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP   13m   k8s-app=kube-dns
kubernetes-dashboard   dashboard-metrics-scraper   ClusterIP   10.96.172.214   <none>        8000/TCP                 12m   k8s-app=dashboard-metrics-scraper
kubernetes-dashboard   kubernetes-dashboard        NodePort    10.96.119.198   <none>        443:30443/TCP            12m   k8s-app=kubernetes-dashboard
```

Kubernetes-dashboard at: https://192.168.50.10:30443/#/login

Enjoy!!