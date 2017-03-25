#!/usr/bin/env bash

PC_DIR="$HOME/.pro-cli"

. $PC_DIR/vars.sh


# # # # # # # # # # # # # # # # # # # #
# show new version info if available
if [ "$PC_VERSION" != "$PC_VERSION_NEW" ]; then
    printf "\n    ${YELLOW}New version available: ${BOLD}${PC_VERSION_NEW}-beta${NORMAL}\n\n"
fi


# # # # # # # # # # # # # # # # # # # #
# show help immediately
if [ $# -eq 0 ] || [ "$1" == "help" ]; then
    help
    exit
fi

# # # # # # # # # # # # # # # # # # # #
# project init [path] [--type=TYPE]
if [ "$1" == "init" ]; then
    shift
    printf "Initializing project files ...\n"
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

    exit
    printf "${GREEN}DONE!${NORMAL}\n"


# # # # # # # # # # # # # # # # # # # #
# get and set config settings
elif [ "$1" == "config" ]; then
    shift

    PC_SELECTION=".${1}"

    if [ ! -z "$2" ]; then
        PC_JSON=$(cat $WDIR/$PC_CONF_FILE | jq "$PC_SELECTION = \"${2}\"" | jq -M .)
        printf "$PC_JSON" > $WDIR/$PC_CONF_FILE
    else
        cat $WDIR/$PC_CONF_FILE | jq "$PC_SELECTION"
    fi

    exit

# # # # # # # # # # # # # # # # # # # #
# project self-update
elif [ "$1" == "self-update" ]; then
    . $PC_DIR/update.sh
    exit
fi


# # # # # # # # # # # # # # # # # # # #
# include the systems
. $PC_DIR/systems/docker-cli.sh
. $PC_DIR/systems/php-cli.sh
. $PC_DIR/systems/laravel-cli.sh
. $PC_DIR/systems/node-cli.sh


# # # # # # # # # # # # # # # # # # # #
# commands that are specified in the local config file
if [ ! -z "$1" ] && [ -f $WDIR/$PC_CONF_FILE ]; then
    IS_OBJECT=$(cat $WDIR/$PC_CONF_FILE | jq -crM --arg cmd "$1" 'if (.scripts[$cmd] | type == "object") then true else false end')

    # get the command by key selection
    if [ "true" == "$IS_OBJECT" ]; then
        COMMAND=$(cat $WDIR/$PC_CONF_FILE | jq -Mr --arg cmd "$1" '.scripts[$cmd]["command"]')
    else
        COMMAND=$(cat $WDIR/$PC_CONF_FILE | jq -Mr --arg cmd "$1" '.scripts[$cmd]')
    fi
    
    if [ ! -z "$COMMAND" ] && [ "$COMMAND" != "null" ]; then
        eval $COMMAND
        exit
    fi
fi

printf "${YELLOW}Command not found ¯\_(ツ)_/¯${NORMAL}\n"
