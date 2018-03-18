#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# show npm commands help if package.json exists
if [ -f "$WDIR/src/package.json" ]; then
    printf "NODE COMMANDS:\n"
    printf "    ${BLUE}npm${NORMAL}${HELP_SPACE:3}Run npm commands.\n"
    printf "    ${BLUE}yarn${NORMAL}${HELP_SPACE:4}Run yarn commands.\n"
fi
