#!/bin/bash

function main() {
    vagrant destroy -f
}

if [ $# == 0 ]; then
    echo " - destroy: destroy your platform!!"
else
    main $@ 
fi