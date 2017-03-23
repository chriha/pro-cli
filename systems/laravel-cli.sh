#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute artisan commands
if [ "$1" == "artisan" ]; then
    shift
    $RUN web php artisan $@
    exit

# # # # # # # # # # # # # # # # # # # #
# interact with the application
elif [ "$1" == "tinker" ]; then
    $RUN web php artisan tinker
    exit
fi
