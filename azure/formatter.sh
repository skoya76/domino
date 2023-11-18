#!/bin/bash

INPUT_FILE="vm_ip_addresses.txt"

awk '
/^vm1-/ {
    region = substr($1, 5)
    gsub("-", "", region)
    print region " " $2 " " $3
}' $INPUT_FILE
