#!/bin/bash

function main() {
    vagrant up
}

function help() {
    echo " - up: platform up!! :) "
}

[ $# == 0 ] && help || main