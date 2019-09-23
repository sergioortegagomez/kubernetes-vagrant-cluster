#!/bin/bash

function ec() {
    echo -e "\033[0;32m| Execute $1 command:\033[0;33m $2 \033[0m"
    echo "$2" | vagrant ssh $1
}

function getNetworkIps() {
    # Private Network for nodes
    PRIVATE_NETWORK_IP=$(echo "sudo ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print \$1}'" | vagrant ssh k8s-master | tail -n 1 | awk '{print $1}')
    PRIVATE_NETWORK_IP_PART1=$(echo $PRIVATE_NETWORK_IP | tr '.' ' ' | awk '{print $1}')
    PRIVATE_NETWORK_IP_PART2=$(echo $PRIVATE_NETWORK_IP | tr '.' ' ' | awk '{print $2}')
    # Private Network for pods
    PRIVATE_SUBNETWORK_IP_PART1=15
    PRIVATE_SUBNETWORK_IP_PART2=15
}

function clusterStart() {
    # Service KubeAdm Start
    ec k8s-master "sudo kubeadm init --apiserver-advertise-address=$PRIVATE_NETWORK_IP_PART1.$PRIVATE_NETWORK_IP_PART2.10.10 --pod-network-cidr=$PRIVATE_SUBNETWORK_IP_PART1.$PRIVATE_SUBNETWORK_IP_PART2.0.0/16"

    # Create vagrant user conf
    ec k8s-master 'mkdir -p $HOME/.kube'
    ec k8s-master 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
    ec k8s-master 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'

    # Join Nodes to Kuberneter
    KUBEADM_JOIN_COMMAND=$(echo 'kubeadm token create --print-join-command' | vagrant ssh k8s-master | grep kubeadm)
    VM_NODES_COUNT=$(vagrant status | grep node- | wc -l)
    for i in `seq 1 $VM_NODES_COUNT`; do
        ec node-$i "sudo $KUBEADM_JOIN_COMMAND"
    done

    # control file deployed
    echo 'touch .deployed' | vagrant ssh k8s-master
}

function calicoNetworkDeploy() {
    ec k8s-master 'wget https://docs.projectcalico.org/v3.9/manifests/calico.yaml'
    ec k8s-master "sed -i \"s#192.168#$PRIVATE_SUBNETWORK_IP_PART1.$PRIVATE_SUBNETWORK_IP_PART2#g\" calico.yaml"
    ec k8s-master 'kubectl apply -f calico.yaml'
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
    ec k8s-master "kubectl taint nodes --all node-role.kubernetes.io/master-"
}

function dashboardDeploy() {
    ec k8s-master 'kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/alternative/kubernetes-dashboard.yaml'
}

function proxyStart() {
    ec k8s-master "echo -e \"#!/bin/bash\nkubectl proxy --address 0.0.0.0 --accept-hosts '.*' &\" > startProxy.sh"
    ec k8s-master "chmod +x startProxy.sh"
    ec k8s-master "bash -c ./startProxy.sh"
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
        proxyStart
    fi

    bash platform-control.sh status

    echo 
    echo "Kubernetes-dashboard at: http://192.168.10.10:8001/api/v1/namespaces/kube-system/services/kubernetes-dashboard/proxy/"
    echo 
}

function help() {
    echo " - up: platform up :) "
}

[ $# == 0 ] && help || main