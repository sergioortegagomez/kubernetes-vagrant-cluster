#!/bin/bash

function ec() {
    echo -e "\033[0;32m| Launching to $1 command:\033[0;33m $2 \033[0m"
    vagrant ssh "$1" -- "$2 2>&1 > /dev/null" 2>&1 > /dev/null
}

function updateEtcHostsFile() {
    echo -e "\033[0;32m| Updating /etc/hosts to master and nodes\033[0;33m \033[0m"
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
}

function clusterStart() {
    # Service KubeAdm Start
    ec k8s-master "sudo kubeadm init --apiserver-advertise-address=192.168.50.10 --apiserver-cert-extra-sans=192.168.50.10  --node-name k8s-master --pod-network-cidr=192.168.0.0/16"

    # Create vagrant user conf
    ec k8s-master 'mkdir -p $HOME/.kube'
    ec k8s-master 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
    ec k8s-master 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'

    # control file deployed
    echo 'touch .deployed' | vagrant ssh k8s-master > /dev/null
}

function joinCluster() {
    # Join Nodes to Kuberneter
    KUBEADM_JOIN_COMMAND=$(echo 'kubeadm token create --print-join-command' | vagrant ssh k8s-master | grep kubeadm)
    VM_NODES_COUNT=$(vagrant status | grep k8s-node- | wc -l)
    for i in `seq 1 $VM_NODES_COUNT`; do
        ec k8s-node-$i "sudo $KUBEADM_JOIN_COMMAND"
    done
}

function weaveNetworkDeploy() {
    ec k8s-master 'kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64)"'
}

function dashboardDeploy() {
    ec k8s-master 'kubectl create deployment http --image=katacoda/docker-http-server:latest'
    ec k8s-master 'kubectl create -f /vagrant/bin/modules/up/Dashboard.yaml'
}

function printDashboardAccess() {
    SECRET_ID=$(vagrant ssh "k8s-master" -- "kubectl -n kubernetes-dashboard get secret"  | grep kubernetes-dashboard-token | awk '{print $1}')
    ACCESS_TOKEN=$(vagrant ssh "k8s-master" -- "kubectl -n kubernetes-dashboard describe secret $SECRET_ID" | grep token: | awk '{print $2}')
    echo
    echo -e "[ Kubernetes Dashboard ]"
    echo -e "Url: https://192.168.50.10:30443/#/login"
    echo -e "AccessToken: $ACCESS_TOKEN"
    echo
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
        updateEtcHostsFile
        clusterStart
        weaveNetworkDeploy
        joinCluster
        dashboardDeploy
        proxyStart
    fi

    bash platform-control.sh status
    printDashboardAccess
}

function help() {
    echo " - up: platform up :) "
}

[ $# == 0 ] && help || main