#!/bin/bash

function main() {
    vagrant reload
    bash platform-control.sh status
}

function help() {
    echo " - restart: vms reboot"
}

[ $# == 0 ] && help || main