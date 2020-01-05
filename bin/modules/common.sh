#!/bin/bash

function printHead() {
    echo
    echo "Kubernetes Vagrant Cluster Platform Control Script"
    echo
}

function help() {
    echo -e "Options:"
    MODULES=$(ls -d modules/*/)
    for MODULE in $MODULES; do
        bash $MODULE/main.sh
    done
    echo -e ""
}

function execute-module() {
    if [ -f "modules/$1/main.sh" ]; then
        modules/$1/main.sh $@
    else
        echo
        echo -e "$1 option not found."
        echo
        help
    fi
}