#!/usr/bin/env bash

PC_DIR="$HOME/.pro-cli"
WDIR=$(pwd)

. $PC_DIR/vars.sh

# # # # # # # # # # # # # # # # # # # #
# show help immediately
if [ $# -eq 0 ] || [ "$1" == "help" ]; then
    help
    exit
fi

# # # # # # # # # # # # # # # # # # # #
# project init [path] [--type=TYPE]
if [ "$1" == "init" ]; then
    shift 1
    printf "Initializing project files ... "
    init_project $@
    printf "${GREEN}DONE!${NORMAL}\n"
    
    exit

# # # # # # # # # # # # # # # # # # # #
# project update
elif [ "$1" == "update" ]; then
    if [ ! -f "$WDIR/.pro-cli" ]; then
        printf "${RED}Not in a pro-cli project!${NORMAL}\n"
        exit
    fi

    printf "${YELLOW}Updating project structure ...${NORMAL} "
    shift 1
    init_project $@
    printf "${GREEN}DONE!${NORMAL}\n"

    printf "${YELLOW}Stopping application ...${NORMAL}\n"
    project down > /dev/null
    printf "${YELLOW}Updating docker images ...${NORMAL}\n"
    docker-compose pull > /dev/null
    printf "${GREEN}Starting application ...${NORMAL}\n"
    project up

    exit

# # # # # # # # # # # # # # # # # # # #
# project install
elif [ "$1" == "install" ]; then
    PC_INSTALL=$(cat $WDIR/$PC_CONF_FILE | jq -rM '.install | .[]' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ \&\& /g')

    printf "${YELLOW}Installing project ...${NORMAL}\n"

    eval $PC_INSTALL

    printf "${GREEN}DONE!${NORMAL}\n"

# # # # # # # # # # # # # # # # # # # #
# project self-update
elif [ "$1" == "self-update" ]; then
    . $PC_DIR/update.sh
fi


# # # # # # # # # # # # # # # # # # # #
# include the systems
. $PC_DIR/systems/docker-cli.sh
. $PC_DIR/systems/php-cli.sh
. $PC_DIR/systems/node-cli.sh


# # # # # # # # # # # # # # # # # # # #
# commands that are specified in the local config file
if [ ! -z "$1" ] && [ -f $WDIR/$PC_CONF_FILE ]; then
    COMMAND=$(cat $WDIR/$PC_CONF_FILE | jq -Mr --arg cmd "$1" '.scripts[$cmd]')

    shift 1
    
    if [ ! -z "$COMMAND" ] && [ "$COMMAND" != "null" ]; then
        eval $COMMAND
    fi
fi
