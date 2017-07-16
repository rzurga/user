#!/usr/bin/env bash
# source all *.sh files in ~/.bashrc.d directory
BASHRC_D_PATH="$HOME/.bashrc.d"
# shopt -s nullglob       # If there is no *.sh files return make return zero entries
if ls $BASHRC_D_PATH/*.sh 1> /dev/null 2>&1; then
    for f in $BASHRC_D_PATH/*.sh; do
        source $f
    done
fi