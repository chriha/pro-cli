#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute composer commands
if [ "$1" == "composer" ]; then
    shift && $RUN $DOCKER_USER_PARAM -v "$(pwd)/temp/composer":"/.composer" web composer $@
    exit

# # # # # # # # # # # # # # # # # # # #
# run php commands
elif [ "$1" == "php" ]; then
    shift && $RUN $DOCKER_USER_PARAM web php $@
    exit

# # # # # # # # # # # # # # # # # # # #
# run tests
elif [ "$1" == "test" ]; then
    shift

    if [ ! -d "./src/vendor" ]; then
        printf "${RED}Vendors not installed. Please run ${BOLD}project composer install${RED} first!${NORMAL}\n" && exit 1
    fi

    $RUN $DOCKER_USER_PARAM web ./vendor/bin/phpunit $@
    exit
fi
