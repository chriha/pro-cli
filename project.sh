#!/usr/bin/env bash

PC_DIR="$HOME/.pro-cli"

# # # # # # # # # # # # # # # # # # # #
# to enable pro-cli in the project, try to
# fetch the working dir via Git
if git status &> /dev/null; then
    WDIR=$(git rev-parse --show-toplevel)
    cd $WDIR
else
    WDIR=$(pwd)
fi

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
    if [ ! -f "$WDIR/$PC_CONF_FILE" ]; then
        printf "${RED}Not in a pro-cli project!${NORMAL}\n"
        exit
    fi

    . $PC_DIR/systems/docker-cli.sh

    printf "${YELLOW}Stopping application ...${NORMAL}\n"
    project down > /dev/null
    printf "${YELLOW}Updating docker images ...${NORMAL}\n"
    $COMPOSE pull

    printf "${GREEN}Project update successfully!${NORMAL}\n"
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
