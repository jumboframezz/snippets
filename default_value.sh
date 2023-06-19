#!/bin/bash

## Set current_user to $1 if not specified current_user=$USER
current_user=${1:-$USER}
echo "Current user: $current_user"

## Assign a value foo to the $USER variable if doesn’t already have one:
unset $var1
echo "${var1:=default_value}"

## Display error if var1 is not defined:
unset var1
echo "${var1?Error var1 is not defined}"