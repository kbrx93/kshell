#! /usr/bin/env bash

set -e

filename=$(readlink -f "$1")
targetDir="${2:-Other}"
arr=("gd-unc-od" "od-21-vip")
command="/usr/bin/rclone copy --rc -P --ignore-existing --drive-acknowledge-abuse "

if [[ -f "${filename}" ]]; then
    for var in ${arr[@]}; do
        ${command} "${filename}" "${var}:/${targetDir}/"
    done
elif [[ -d "${filename}" ]]; then
    for var in ${arr[@]}; do
        ${command} "${filename}" "${var}:/${targetDir}/${1}"
    done
else
    echo "input error"
fi
