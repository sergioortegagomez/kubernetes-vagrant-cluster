#!/bin/bash

function main() {
    vagrant reload

    # Service KubeAdm Start
    echo "sudo kubeadm init --apiserver-advertise-address=192.168.10.10 --apiserver-cert-extra-sans=192.168.10.10  --node-name k8s-master --pod-network-cidr=192.168.0.0/16" | vagrant ssh k8s-master

    # Create vagrant user conf
    echo 'mkdir -p $HOME/.kube' | vagrant ssh k8s-master
    echo 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config' | vagrant ssh k8s-master
    echo 'sudo chown $(id -u):$(id -g) $HOME/.kube/config' | vagrant ssh k8s-master

    # Join Nodes to Kuberneter
    KUBEADM_JOIN_COMMAND=$(echo 'kubeadm token create --print-join-command' | vagrant ssh k8s-master | grep kubeadm)
    for i in `seq 1 5`; do
        echo "sudo $KUBEADM_JOIN_COMMAND" | vagrant ssh node-$i
    done
    echo 'kubectl get nodes' | vagrant ssh k8s-master
}

function help() {
    echo " - restart: vms reboot"
}

[ $# == 0 ] && help || main