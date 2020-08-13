#!/bin/bash

function onError() {
    printf "Error occurred! Aborting..."
    exit 1
}

trap onError ERR

# Clear build dir
printf "Clearing build dir\n"
rm -rf build/*

# Copy over src
printf "Copying src\n"
cp -r src/* build/

# Copy license
printf "Copying LICENSE\n"
cp LICENSE build/

printf "Done!\n"
