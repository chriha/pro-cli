#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute npm commands
if [ "$1" == "node" ]; then
    shift
    $RUN $DOCKER_USER_PARAM -v "$(pwd)/temp/npm":"/.npm" node node $@
    exit

# # # # # # # # # # # # # # # # # # # #
# execute npm commands
elif [ "$1" == "npm" ]; then
    shift
    $RUN $DOCKER_USER_PARAM -v "$(pwd)/temp/npm":"/.npm" node npm $@
    exit

# # # # # # # # # # # # # # # # # # # #
# execute yarn commands
elif [ "$1" == "yarn" ]; then
    shift
    $RUN -v "$(pwd)/temp/yarn":"/.yarn" yarn yarn $@
    exit
fi
