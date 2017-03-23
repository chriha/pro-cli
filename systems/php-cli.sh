#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute composer commands
if [ "$1" == "composer" ]; then
    shift 1
    $RUN web composer "$@"
    exit

# # # # # # # # # # # # # # # # # # # #
# execute artisan commands
elif [ "$1" == "artisan" ]; then
    shift 1
    $RUN web php artisan "$@"
    exit

# # # # # # # # # # # # # # # # # # # #
# interact with the application
elif [ "$1" == "tinker" ]; then
    $RUN web php artisan tinker
    exit

# # # # # # # # # # # # # # # # # # # #
# run tests
elif [ "$1" == "test" ]; then
    shift 1
    
    if [ ! -d "./vendor" ]; then
        printf "${RED}Vendors not installed. Please run ${BOLD}$0 composer install${RED} first!${NORMAL}\n"
        exit
    fi

    $RUN web ./vendor/bin/phpunit "$@"
    exit

# # # # # # # # # # # # # # # # # # # #
# just a bit faster then the "test" command
elif [ "$1" == "t" ]; then
    shift 1
    $COMPOSE exec web sh -c "cd /var/www && ./vendor/bin/phpunit $@"
    exit
fi
