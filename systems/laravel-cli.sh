#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute artisan commands
if [ "$1" == "artisan" ]; then
    if ( needs_help $@ ); then
        printf "${YELLOW}usage:${NORMAL} project artisan [command] [options]\n\n"
        exit
    fi

    shift
    $RUN $PC_USER_PARAM web php artisan $@ 2> $OUTPUT_FILE
    exit

# # # # # # # # # # # # # # # # # # # #
# interact with the application
elif [ "$1" == "tinker" ]; then
    $RUN $PC_USER_PARAM web php artisan tinker 2> $OUTPUT_FILE
    exit

# # # # # # # # # # # # # # # # # # # #
# execute laravel-echo-server commands
elif [ "$1" == "echo" ]; then
    $RUN $PC_USER_PARAM echo laravel-echo-server 2> $OUTPUT_FILE
    exit
fi
