#!/bin/bash

function main() {
    vagrant destroy -f
}

function help() {
    echo " - destroy: destroy your platform!!"
}

[ $# == 0 ] && help || main