#!/bin/bash

PRIVATE_NETWORK_IP=$(sudo ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

function printTitle() {
    echo "-[ $1 ]-"
}

# Docker Install
function dockerInstall() {
    printTitle "Docker Install"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get upgrade
    sudo apt-get -y install apt-transport-https ca-certificates vim curl gnupg2 software-properties-common docker-ce docker-ce-cli containerd.io
    sudo usermod -aG docker vagrant
    cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF
    mkdir -p /etc/systemd/system/docker.service.d
    systemctl daemon-reload
    systemctl restart docker
}

# Disabled SWAP
function disableSWAP() {
    printTitle "Disable SWAP"
    sed -i '/swap/d' /etc/fstab
    swapoff -a
    mount -a
}

# Kube* Install
function kubeInstall() {
    printTitle "Kube Install"
    curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
    sudo add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
    sudo apt-get update
    sudo apt-get -y install kubelet kubeadm kubectl
    sudo apt-mark hold kubelet kubeadm kubectl
    kubeadm init phase kubelet-start
    echo "KUBELET_EXTRA_ARGS=--node-ip=$PRIVATE_NETWORK_IP" > /var/lib/kubelet/kubeadm-flags.env
}

# main
function main() {
    dockerInstall
    disableSWAP
    kubeInstall
}

main