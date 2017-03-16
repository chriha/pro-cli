#!/usr/bin/env bash

if [ "$1" == "npm" ]; then
    shift 1
    $RUN node npm "$@"
elif [ -f $GULP ] && [ "$1" == "gulp" ]; then
    shift 1

    if [ ! -d "./src/node_modules" ]; then
        printf "${RED}Node not installed. Please run ${BOLD}$0 npm install${RED} first!${NORMAL}\n"
        exit
    fi

    $RUN node ./node_modules/.bin/gulp "$@"
elif [ "$1" == "yarn" ]; then
    shift 1
    $RUN yarn yarn "$@"
fi
