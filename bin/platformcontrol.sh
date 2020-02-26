#!/bin/bash

cd "$(dirname $0)"

source modules/common.sh

printHead

[ $# == 0 ] && help || execute-module $@