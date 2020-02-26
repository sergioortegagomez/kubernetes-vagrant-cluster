#!/bin/bash

function main() {
    vagrant reload
    bash platformcontrol.sh status
}

function help() {
    echo " - restart: vms reboot"
}

[ $# == 0 ] && help || main