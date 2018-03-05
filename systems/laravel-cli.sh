#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute artisan commands
if [ "$1" == "artisan" ]; then
    if ( needs_help $@ ); then
        printf "${YELLOW}usage:${NORMAL} project artisan [command] [options]\n\n"
        exit
    fi

    shift

    PC_HAS_WEB=$(is_service_running web)

    if [ "$PC_HAS_WEB" == "true" ]; then
        $COMPOSE exec web sh -c "cd /var/www && php artisan $@"
    else
        $RUN $PC_USER_PARAM web php artisan $@ 2> $OUTPUT_FILE
    fi

    exit

# # # # # # # # # # # # # # # # # # # #
# interact with the application
elif [ "$1" == "tinker" ]; then

    PC_HAS_WEB=$(is_service_running web)

    if [ "$PC_HAS_WEB" == "true" ]; then
        $COMPOSE exec web sh -c "cd /var/www && php artisan tinker $@" 2> $OUTPUT_FILE
    else
        $RUN $PC_USER_PARAM web php artisan tinker 2> $OUTPUT_FILE
    fi

    exit

# # # # # # # # # # # # # # # # # # # #
# execute laravel-echo-server commands
elif [ "$1" == "echo" ]; then
    shift

    PC_HAS_WEB=$(is_service_running web)

    if [ "$PC_HAS_WEB" == "true" ]; then
        $COMPOSE exec echo  sh -c "cd /var/www && laravel-echo-server $@" 2> $OUTPUT_FILE
    else
        $RUN $PC_USER_PARAM echo laravel-echo-server $@ 2> $OUTPUT_FILE
    fi

    exit
fi
