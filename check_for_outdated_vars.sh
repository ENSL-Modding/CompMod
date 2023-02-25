#!/bin/bash

test $1 || { echo "Usage: $0 ns2_install_path"; exit 1; }
install_path="$1"
shift

python3 scripts/var_checker.py src/lua/CompMod src/lua/CompMod/Globals/Balance.lua "$install_path/ns2/lua/Balance.lua" "$install_path/ns2/lua/BalanceHealth.lua" "$install_path/ns2/lua/BalanceMisc.lua"
exit $?
