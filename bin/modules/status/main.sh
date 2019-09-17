#!/bin/bash

function main() {
    vagrant status
}

if [ $# == 0 ]; then
    echo " - status: Current Platform status"
else
    main $@ 
fi