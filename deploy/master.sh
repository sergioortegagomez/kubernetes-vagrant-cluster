#!/bin/bash

PRIVATE_NETWORK_IP=$(sudo ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
    
function printTitle() {
    echo "=================================================="
    echo "= $1"
}

# Docker Install
function dockerInstall() {
    printTitle "Docker Install"
    sudo apt-get update
    sudo apt-get -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get -y install docker-ce
    sudo usermod -aG docker vagrant
}

# Disabled SWAP
function disableSWAP() {
    printTitle "Disables SWAP"
    swapoff -a
    LINE=$(sudo cat /etc/fstab | grep swap | grep -v "#")
    sudo sed -i "s#$LINE#\#$LINE#g" /etc/fstab
    mount -a
    free -h
}

# Kube* Install
function kubeInstall() {
    printTitle "Kube Install"
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
    sudo apt-get update
    sudo apt-get -y install kubelet kubeadm kubectl
    echo "KUBELET_EXTRA_ARGS=--node-ip=$PRIVATE_NETWORK_IP" > /etc/default/kubelet
    sudo service kubelet restart
    sudo kubelet --version
}

# Service KubeAdm Start
function startKubeAdm() {
    IP_PART1=$(echo $PRIVATE_NETWORK_IP | tr '.' ' ' | awk '{ print $1 }')
    IP_PART2=$(echo $PRIVATE_NETWORK_IP | tr '.' ' ' | awk '{ print $2 }')
    sudo kubeadm init --apiserver-advertise-address="$PRIVATE_NETWORK_IP" --apiserver-cert-extra-sans="$PRIVATE_NETWORK_IP"  --node-name k8s-master --pod-network-cidr=$IP_PART1.$IP_PART2.0.0/16
}

# main
function main() {
    dockerInstall
    disableSWAP
    kubeInstall
    startKubeAdm
}

main