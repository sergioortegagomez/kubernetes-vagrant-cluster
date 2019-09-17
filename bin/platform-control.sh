#!/bin/bash

cd "$(dirname $0)"

source modules/common.sh

printHead

if [ $# == 0 ]; then
    help
else
    execute-module $@ 
fi