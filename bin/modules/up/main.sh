#!/bin/bash

function ec() {
    echo -e "\033[0;32m| Execute $1 command:\033[0;33m $2 \033[0m"
    vagrant ssh "$1" -- "$2"
}

function getNetworkIps() {
    # Private Network for nodes
    PRIVATE_NETWORK_IP=$(echo "sudo ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}'" | vagrant ssh k8s-master | tail -n 1 | awk '{print $1}')
    PRIVATE_NETWORK_IP_PART1=$(echo $PRIVATE_NETWORK_IP | tr '.' ' ' | awk '{print $1}')
    PRIVATE_NETWORK_IP_PART2=$(echo $PRIVATE_NETWORK_IP | tr '.' ' ' | awk '{print $2}')

    #Update /etc/host
    vagrant ssh k8s-master -- "sudo chmod 777 /etc/hosts"    
    VM_NODES_COUNT=$(vagrant status | grep k8s-node- | wc -l)
    for i in `seq 1 $VM_NODES_COUNT`; do
        vagrant ssh k8s-node-$i -- "sudo chmod 777 /etc/hosts"
    done
    for i in `seq 1 $VM_NODES_COUNT`; do
        NODE_PRIVATE_NETWORK_IP=$(echo "sudo ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}'" | vagrant ssh k8s-node-$i | tail -n 1 | awk '{print $1}')
        for j in `seq 1 $VM_NODES_COUNT`; do
            vagrant ssh k8s-node-$j -- "sudo echo \"$NODE_PRIVATE_NETWORK_IP k8s-node-$i\" >> /etc/hosts"            
        done        
        vagrant ssh k8s-master -- "sudo echo \"$NODE_PRIVATE_NETWORK_IP k8s-node-$i\" >> /etc/hosts"        
    done
    for i in `seq 1 $VM_NODES_COUNT`; do
        vagrant ssh k8s-node-$i -- "sudo chmod 644 /etc/hosts"
    done
    vagrant ssh k8s-master -- "sudo chmod 644 /etc/hosts"
    ec k8s-master "cat /etc/hosts"
}

function clusterStart() {
    # Service KubeAdm Start
    ec k8s-master "sudo kubeadm init --apiserver-advertise-address=$PRIVATE_NETWORK_IP_PART1.$PRIVATE_NETWORK_IP_PART2.10.10 --apiserver-cert-extra-sans=$PRIVATE_NETWORK_IP_PART1.$PRIVATE_NETWORK_IP_PART2.10.10  --pod-network-cidr=$PRIVATE_NETWORK_IP_PART1.$PRIVATE_NETWORK_IP_PART2.0.0/16"

    # Create vagrant user conf
    ec k8s-master 'mkdir -p $HOME/.kube'
    ec k8s-master 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
    ec k8s-master 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'

    # control file deployed
    echo 'touch .deployed' | vagrant ssh k8s-master
}

function joinNodes() {
    # Join Nodes to Kuberneter
    KUBEADM_JOIN_COMMAND=$(echo 'kubeadm token create --print-join-command' | vagrant ssh k8s-master | grep kubeadm)
    VM_NODES_COUNT=$(vagrant status | grep k8s-node- | wc -l)
    for i in `seq 1 $VM_NODES_COUNT`; do
        ec k8s-node-$i "sudo $KUBEADM_JOIN_COMMAND"
    done
}

function calicoNetworkDeploy() {
    ec k8s-master 'kubectl apply -f https://docs.projectcalico.org/v3.9/manifests/calico.yaml'    
    sleep 5

    PODS_CALICO_COUNT=$(echo "kubectl get pods -o wide --all-namespaces | grep calico | wc -l" | vagrant ssh k8s-master | tail -n 1)
    PODS_CALICO_RUNNING=0
    echo -e "Waiting for calico (aprox 3 minutes)"
    while [ $PODS_CALICO_RUNNING -lt $PODS_CALICO_COUNT ]; do
        sleep 5
        PODS_CALICO_RUNNING=$(echo "kubectl get pods -o wide --all-namespaces | grep calico | grep Running | wc -l" | vagrant ssh k8s-master | tail -n 1)
        echo -n "."
    done
    echo -e ""
}

function dashboardDeploy() {
    # Deploy Dashboard
    ec k8s-master 'kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/head.yaml'
    ec k8s-master 'kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/aio/deploy/recommended.yaml'
    
    # Get token account
    POD_NAME=$(echo "kubectl -n kubernetes-dashboard get secret | grep kubernetes-dashboard" | vagrant ssh k8s-master | tail -n 1 | awk '{print $1}')
    ec k8s-master "kubectl -n kubernetes-dashboard describe secret $POD_NAME"
}

function proxyStart() {
    vagrant ssh k8s-master -- "nohup kubectl proxy --address 0.0.0.0 --accept-hosts '^*$'" &
}

function main() {
    vagrant up

    # First time only
    IS_DEPLOYED=$(echo 'ls -la' | vagrant ssh k8s-master | grep deployed | wc -l)
    if [ ${IS_DEPLOYED} == 0 ]; then
        bash platform-control.sh restart
        #getNetworkIps
        clusterStart
        calicoNetworkDeploy
        joinNodes
        dashboardDeploy
        proxyStart
    fi

    bash platform-control.sh status

    echo 
    echo "Kubernetes-dashboard at: http://192.168.10.10:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login"
    echo 
}

function help() {
    echo " - up: platform up :) "
}

[ $# == 0 ] && help || main