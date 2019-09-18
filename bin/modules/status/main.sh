#!/bin/bash

function main() {
    vagrant status
}

function help() {
    echo " - status: Current Platform status"
}

[ $# == 0 ] && help || main