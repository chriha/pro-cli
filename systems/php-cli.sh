#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute composer commands
if [ "$1" == "composer" ]; then
    shift

    PC_HAS_WEB=$(is_service_running web)

    if [ "$PC_HAS_WEB" == "true" ]; then
        $COMPOSE exec web composer $@
    else
        $RUN $PC_USER_PARAM -v "$(pwd)/temp/composer":"/.composer" web composer $@
    fi

    exit

# # # # # # # # # # # # # # # # # # # #
# run php commands
elif [ "$1" == "php" ]; then
    shift

    PC_HAS_WEB=$(is_service_running web)

    if [ "$PC_HAS_WEB" == "true" ]; then
        $COMPOSE exec web php $@
    else
        $RUN $PC_USER_PARAM web php $@
    fi

    exit

# # # # # # # # # # # # # # # # # # # #
# run tests
elif [ "$1" == "test" ]; then
    shift

    PC_HAS_WEB=$(is_service_running web)

    if [ ! -d "./src/vendor" ]; then
        printf "${RED}Vendors not installed. Please run ${BOLD}project composer install${RED} first!${NORMAL}\n"
        exit
    fi

    if [ "$PC_HAS_WEB" == "true" ]; then
        $COMPOSE exec web sh -c "cd /var/www && ./vendor/bin/phpunit $@"
    else
        $RUN $PC_USER_PARAM web ./vendor/bin/phpunit $@
    fi

# # # # # # # # # # # # # # # # # # # #
# just a bit faster then the "test" command
elif [ "$1" == "t" ]; then
    shift
    $COMPOSE exec web sh -c "cd /var/www && ./vendor/bin/phpunit $@"
    exit
fi
