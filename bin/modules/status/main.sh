#!/bin/bash

function main() {
    vagrant status
    IS_K8SMASTER_RUNNING=$(vagrant status | grep k8s-master | awk '{print $2}')
    if [ "${IS_K8SMASTER_RUNNING}" == "running" ]; then
        IS_DEPLOYED=$(echo 'ls -la' | vagrant ssh k8s-master | grep deployed | wc -l)
        if [ ${IS_DEPLOYED} == 1 ]; then
            echo -e "[ Nodes ]"
            vagrant ssh k8s-master -- 'kubectl get nodes --all-namespaces -o wide'
            echo -e "[ Pods ]"
            vagrant ssh k8s-master -- 'kubectl get pods --all-namespaces -o wide'
            echo -e "[ Services ]"
            vagrant ssh k8s-master -- 'kubectl get services --all-namespaces -o wide'
        fi
    fi
}

function help() {
    echo " - status: current vms and kubectl status"
}

[ $# == 0 ] && help || main