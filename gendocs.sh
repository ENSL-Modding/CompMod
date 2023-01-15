#!/bin/bash

fileHooksPath="src/lua/CompMod_FileHooks.lua"
install_path="$1"
vanilla_build="$2"
shift 2

test -z "$install_path" && { echo "Usage: $0 [ns2_install_path] [vanilla_build]"; exit 1; }
test -z "$vanilla_build" && { echo "Usage: $0 [ns2_install_path] [vanilla_build]"; exit 1; }

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
    python3 scripts/docugen.py gen src/lua/CompMod/Globals/Balance.lua $install_path/ns2/lua/Balance.lua $install_path/ns2/lua/BalanceHealth.lua $install_path/ns2/lua/BalanceMisc.lua $vanilla_build $current_revision
else
    python3 scripts/docugen.py gen src/lua/CompMod/Globals/Balance.lua $install_path/ns2/lua/Balance.lua $install_path/ns2/lua/BalanceHealth.lua $install_path/ns2/lua/BalanceMisc.lua $vanilla_build $current_revision $current_beta_revision
fi
test "$?" || { echo "ERROR: Docugen returned a non-zero return-code"; exit 1; }
