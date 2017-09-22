#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute artisan commands
if [ "$1" == "artisan" ]; then
    if ( needs_help $@ ); then
        printf "${YELLOW}usage:${NORMAL} project artisan [command] [options]\n\n"
        exit
    fi

    shift
    $RUN web php artisan $@ 2> $OUTPUT_FILE
    exit

# # # # # # # # # # # # # # # # # # # #
# interact with the application
elif [ "$1" == "tinker" ]; then
    $RUN web php artisan tinker 2> $OUTPUT_FILE
    exit
fi
