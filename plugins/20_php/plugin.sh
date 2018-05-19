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

# # # # # # # # # # # # # # # # # # # #
# enable / disable xdebug
elif [ "$1" == "xdebug" ]; then
    shift

    if [ "$1" == "enable" ]; then
        HOST_IP=$(ifconfig | grep 'inet 192.' | head -1 | awk '{ printf $2 }')
        project exec web sed -i '' -e "s/xdebug.remote_host=.*/xdebug.remote_host=$HOST_IP/g" "/etc/php/7.1/mods-available/xdebug.ini"
        project exec web ln -fs /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/cli/conf.d/20-xdebug.ini
        project exec web ln -fs /etc/php/7.1/mods-available/xdebug.ini /etc/php/7.1/fpm/conf.d/20-xdebug.ini
        project exec web service php7.1-fpm restart &> /dev/null
        printf "Xdebug is now ${GREEN}enabled${NORMAL}\n"
        exit
    elif [ "$1" == "disable" ]; then
        project exec web rm -f /etc/php/7.1/cli/conf.d/20-xdebug.ini
        project exec web rm -f /etc/php/7.1/fpm/conf.d/20-xdebug.ini
        project exec web service php7.1-fpm restart &> /dev/null
        printf "Xdebug is now ${RED}disabled${NORMAL}\n"
        exit
    elif [ "$1" == "status" ]; then
        if project exec web php -i | grep xdebug &> /dev/null; then
            printf "Xdebug is ${GREEN}enabled${NORMAL}\n"
        else
            printf "Xdebug is ${RED}disabled${NORMAL}\n"
        fi

        exit
    fi
fi
