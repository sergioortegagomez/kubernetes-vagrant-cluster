#!/bin/bash

function main() {
    vagrant halt
}

function help() {
    echo " - halt: shutdown all vms"
}

[ $# == 0 ] && help || main