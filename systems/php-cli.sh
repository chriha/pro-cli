#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute composer commands
if [ "$1" == "composer" ]; then
    shift
    $RUN -v "$(pwd)/temp/composer":"/.composer" web composer $@
    exit

# # # # # # # # # # # # # # # # # # # #
# run php commands
elif [ "$1" == "php" ]; then
    shift

    $RUN web php $@
    exit

# # # # # # # # # # # # # # # # # # # #
# run tests
elif [ "$1" == "test" ]; then
    shift

    if [ ! -d "./src/vendor" ]; then
        printf "${RED}Vendors not installed. Please run ${BOLD}$0 composer install${RED} first!${NORMAL}\n"
        exit
    fi

    $RUN web ./vendor/bin/phpunit $@
    exit

# # # # # # # # # # # # # # # # # # # #
# just a bit faster then the "test" command
elif [ "$1" == "t" ]; then
    shift
    $COMPOSE exec web sh -c "cd /var/www && ./vendor/bin/phpunit $@"
    exit
fi
