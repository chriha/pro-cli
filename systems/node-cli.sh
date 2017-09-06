#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute npm commands
if [ "$1" == "npm" ]; then
    shift
    $RUN node npm $@
    exit

# # # # # # # # # # # # # # # # # # # #
# execute yarn commands
elif [ "$1" == "yarn" ]; then
    shift
    $RUN yarn yarn $@
    exit
fi
