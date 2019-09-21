#!/bin/bash

function main() {
    vagrant up
    bash platform-control.sh restart
}

function help() {
    echo " - up: platform up :) "
}

[ $# == 0 ] && help || main