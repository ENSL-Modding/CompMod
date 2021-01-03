#!/bin/bash

function on_error() {
    printf "Error occurred! Aborting..."
    exit 1
}

function make() {
    make_clean

    # Recreate
    mkdir build

    # Copy over src
    printf "Copying src\n"
    cp -r src/* build/

    # Clear .docugen files
    printf "Clearing .docugen files\n"
    find build/lua/* -type f -name ".docugen" -delete > /dev/null

    # Copy license
    printf "Copying LICENSE\n"
    cp LICENSE build/ 2>/dev/null || printf "\e[93mWarning\e[0m: no LICENSE file found!\n"

    printf "Done!\n"
}

function make_clean() {
    printf "Cleaning build dir\n"
    rm -rf build
}

trap on_error ERR

if [[ $1 == "clean" ]]
then
    make_clean
else
    make
fi
