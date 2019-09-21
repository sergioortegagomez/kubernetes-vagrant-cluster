#!/bin/bash

function clusterStart() {
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

    # control file deployed
    echo 'touch .deployed' | vagrant ssh k8s-master
}

function dashboardDeploy() {
    echo 'kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml' | vagrant ssh k8s-master
    echo "kubectl proxy --accept-hosts='^localhost$,^127\.0\.0\.1$,^\[::1\]$' &" | vagrant ssh k8s-master
}

function main() {
    vagrant up

    # First time only
    IS_DEPLOYED=$(echo 'ls -la' | vagrant ssh k8s-master | grep deployed | wc -l)
    if [ ${IS_DEPLOYED} == 0 ]; then
        bash platform-control.sh restart
        clusterStart
        # dashboardDeploy
    fi

    bash platform-control.sh status
}

function help() {
    echo " - up: platform up :) "
}

[ $# == 0 ] && help || main