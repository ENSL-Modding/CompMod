#!/bin/bash

fileHooksPath="src/lua/CompMod_FileHooks.lua"
vanilla_build="$1"
shift

test -z "$vanilla_build" && { echo "No vanilla version provided. Please provide the current vanilla build number as an argument to this script"; exit 1; }

# Attempt to extract revision numbers from Filehooks file
current_revision="$(cat $fileHooksPath | grep -oP 'g_compModRevision = \K[0-9]+')"
current_beta_revision="$(cat $fileHooksPath | grep -oP 'g_compModBeta = \K[0-9]+')"

test -z "$current_revision" && { echo "Failed to lookup current revision"; exit 1; }
test -z "$current_beta_revision" && { echo "Failed to lookup current beta revision"; exit 1; }

echo -n "Generating docs for CompMod revision $current_revision"
test "$current_beta_revision" -eq 0 || echo -n " beta $current_beta_revision"
echo -en "\n"

# Generate docs
if [ "$current_beta_revision" -eq 0 ]; then
    python3 docugen.py gen $vanilla_build $current_revision
else
    python3 docugen.py gen $vanilla_build $current_revision $current_beta_revision
fi
test "$?" || { echo "ERROR: Docugen returned a non-zero return-code"; exit 1; }
