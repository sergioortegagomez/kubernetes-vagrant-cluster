#!/bin/bash

function main() {
    vagrant up
}

if [ $# == 0 ]; then
    echo " - up: platform up!! :) "
else
    main $@ 
fi