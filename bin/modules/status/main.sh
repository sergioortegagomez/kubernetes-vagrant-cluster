#!/bin/bash

function main() {
    vagrant status
}

function help() {
    echo " - status: current status"
}

[ $# == 0 ] && help || main