#!/usr/bin/env bash

build_dir="build"

test -d "$build_dir" || { echo "No build; run ./create_build.sh"; exit 1; }
test -f "$build_dir/workshopitem.vdf" || { echo "Not a steamcmd build; aborting"; exit 1; }

steamcmd +login ensl_compmod +workshop_build_item $(pwd)/build/workshopitem.vdf +quit || {
    echo "Workshop publish failed";
    exit 1;
}

rm -rf "$build_dir"

echo
echo "Publish successful"
