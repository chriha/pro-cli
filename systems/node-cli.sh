#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute npm commands
if [ "$1" == "npm" ]; then
    shift 1
    $RUN node npm "$@"
    exit

# # # # # # # # # # # # # # # # # # # #
# execute yarn commands
elif [ "$1" == "yarn" ]; then
    shift 1
    $RUN yarn yarn "$@"
    exit
fi
