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
    sudo apt-get -y install apt-transport-https ca-certificates vim curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get -y install docker-ce
    sudo usermod -aG docker vagrant
}

# Disabled SWAP
function disableSWAP() {
    printTitle "Disable SWAP"
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
    sudo apt-mark hold kubelet kubeadm kubectl
    echo "KUBELET_EXTRA_ARGS=--node-ip=$PRIVATE_NETWORK_IP" > /etc/default/kubelet
}

# Enable cgroups memory for default Jessie image.
function enableCgroupsMemory() {
    printTitle "Enable Cgroups Memory"
    sudo sed -i "s#quiet#quiet cgroup_enable=memory swapaccount=1#g" /etc/default/grub
    sudo update-grub2
}


# main
function main() {
    dockerInstall
    disableSWAP
    kubeInstall
    enableCgroupsMemory
}

main