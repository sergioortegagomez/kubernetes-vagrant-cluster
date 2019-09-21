#!/bin/bash

function main() {
    vagrant destroy -f
}

function help() {
    echo " - destroy: destroy and remove all vms"
}

[ $# == 0 ] && help || main