#!/bin/bash

function main() {
    vagrant status
    IS_K8SMASTER_RUNNING=$(vagrant status | grep k8s-master | awk '{print $2}')
    if [ "${IS_K8SMASTER_RUNNING}" == "running" ]; then
        IS_DEPLOYED=$(echo 'ls -la' | vagrant ssh k8s-master | grep deployed | wc -l)
        if [ ${IS_DEPLOYED} == 1 ]; then
            echo 'kubectl get nodes -o wide' | vagrant ssh k8s-master
            echo 'kubectl cluster-info' | vagrant ssh k8s-master
        fi
    fi
}

function help() {
    echo " - status: current vms and kubectl status"
}

[ $# == 0 ] && help || main