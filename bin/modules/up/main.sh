#!/bin/bash

function ec() {
    echo "| Execute $2 command: $1"
    echo "$1" | vagrant ssh $2
}

function getNetworkIps() {
    PRIVATE_NETWORK_IP=$(echo "sudo ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}'" | vagrant ssh k8s-master | tail -n 1 | awk '{print $1}')
    PRIVATE_NETWORK_IP_PART1=$(echo $PRIVATE_NETWORK_IP | tr '.' ' ' | awk '{print $1}')
    PRIVATE_NETWORK_IP_PART2=$(echo $PRIVATE_NETWORK_IP | tr '.' ' ' | awk '{print $2}')

    PRIVATE_SUBNETWORK_IP=$(echo "sudo ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}'" | vagrant ssh k8s-master | tail -n 1 | awk '{print $1}')
    PRIVATE_SUBNETWORK_IP_PART1=$(echo $PRIVATE_SUBNETWORK_IP | tr '.' ' ' | awk '{print $1}')
    PRIVATE_SUBNETWORK_IP_PART2=$(echo $PRIVATE_SUBNETWORK_IP | tr '.' ' ' | awk '{print $2}')
}

function clusterStart() {
    # Service KubeAdm Start
    ec "sudo kubeadm init --apiserver-advertise-address=$PRIVATE_NETWORK_IP_PART1.$PRIVATE_NETWORK_IP_PART2.10.10 --apiserver-cert-extra-sans=$PRIVATE_NETWORK_IP_PART1.$PRIVATE_NETWORK_IP_PART2.10.10 --node-name k8s-master --pod-network-cidr=$PRIVATE_SUBNETWORK_IP_PART1.$PRIVATE_SUBNETWORK_IP_PART2.0.0/16" k8s-master

    # Create vagrant user conf
    ec 'mkdir -p $HOME/.kube' k8s-master
    ec 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config' k8s-master
    ec 'sudo chown $(id -u):$(id -g) $HOME/.kube/config' k8s-master

    # Join Nodes to Kuberneter
    KUBEADM_JOIN_COMMAND=$(echo 'kubeadm token create --print-join-command' | vagrant ssh k8s-master | grep kubeadm)
    for i in `seq 1 5`; do
        ec "sudo $KUBEADM_JOIN_COMMAND" node-$i
    done

    # control file deployed
    echo 'touch .deployed' | vagrant ssh k8s-master
}

function calicoNetworkDeploy() {
    ec 'wget https://docs.projectcalico.org/v3.9/manifests/calico.yaml' k8s-master
    ec "sed -i \"s#192.168#$PRIVATE_SUBNETWORK_IP_PART1.$PRIVATE_SUBNETWORK_IP_PART2#g\" calico.yaml" k8s-master
    ec 'kubectl apply -f calico.yaml' k8s-master
    sleep 5
    PODS_CALICO_COUNT=$(echo "kubectl get pods -o wide --all-namespaces | grep calico | wc -l" | vagrant ssh k8s-master | tail -n 1)
    PODS_CALICO_RUNNING=0
    echo -e "Waiting for calico"
    while [ $PODS_CALICO_RUNNING -lt $PODS_CALICO_COUNT ]; do
        sleep 1
        PODS_CALICO_RUNNING=$(echo "kubectl get pods -o wide --all-namespaces | grep calico | grep Running | wc -l" | vagrant ssh k8s-master | tail -n 1)
        echo -n "."
    done
    echo -e ""
    ec "kubectl taint nodes --all node-role.kubernetes.io/master-" k8s-master
}

function dashboardDeploy() {
    ec 'kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/alternative/kubernetes-dashboard.yaml' k8s-master
    #echo "kubectl proxy --address 0.0.0.0 --accept-hosts '.*' &" | vagrant ssh k8s-master
}

function main() {
    vagrant up

    # First time only
    IS_DEPLOYED=$(echo 'ls -la' | vagrant ssh k8s-master | grep deployed | wc -l)
    if [ ${IS_DEPLOYED} == 0 ]; then
        bash platform-control.sh restart
        getNetworkIps
        clusterStart
        calicoNetworkDeploy
        dashboardDeploy
    fi

    bash platform-control.sh status
}

function help() {
    echo " - up: platform up :) "
}

[ $# == 0 ] && help || main