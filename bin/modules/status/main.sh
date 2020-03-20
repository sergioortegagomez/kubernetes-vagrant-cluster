#!/bin/bash

function printDashboardAccess() {
    SECRET_ID=$(vagrant ssh "k8s-master" -- "kubectl -n kubernetes-dashboard get secret"  | grep kubernetes-dashboard-token | awk '{print $1}')
    ACCESS_TOKEN=$(vagrant ssh "k8s-master" -- "kubectl -n kubernetes-dashboard describe secret $SECRET_ID" | grep token: | awk '{print $2}')
    echo
    echo -e "[ Kubernetes Dashboard ]"
    echo -e "Url: https://192.168.50.10:30443/#/login"
    echo -e "AccessToken: $ACCESS_TOKEN"
    echo
}

function main() {
    vagrant status
    IS_K8SMASTER_RUNNING=$(vagrant status | grep k8s-master | awk '{print $2}')
    if [ "${IS_K8SMASTER_RUNNING}" == "running" ]; then
        IS_DEPLOYED=$(echo 'ls -la' | vagrant ssh k8s-master | grep deployed | wc -l)
        if [ ${IS_DEPLOYED} == 1 ]; then
            for t in nodes pods services; do
                echo
                echo -e "[ $t ]"
                vagrant ssh k8s-master -- "kubectl get $t --all-namespaces -o wide"
            done
        fi
    fi
    printDashboardAccess
}

function help() {
    echo " - status: current vms and kubectl status"
}

[ $# == 0 ] && help || main