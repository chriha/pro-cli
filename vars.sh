#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# to enable pro-cli in the project, try to
# fetch the working dir via Git
if git status &> /dev/null; then
    WDIR=$(git rev-parse --show-toplevel)
    cd $WDIR
else
    WDIR=$(pwd)
fi

# current system
PC_SYSTEM=$(uname -s)
# current pro-cli version
PC_VERSION=$(cd $PC_DIR && git describe --tags)

if [ "$PC_SYSTEM" == "Darwin" ]; then
    PC_LATEST_FETCH=$(expr $(date +%s) - $(stat -f %m $PC_DIR/.git/FETCH_HEAD))
else
    PC_LATEST_FETCH=$(expr $(date +%s) - $(stat -c %Y $PC_DIR/.git/FETCH_HEAD))
fi

# check for new version
if [ $PC_LATEST_FETCH -gt 1800 ]; then
    # only fetch every 30 minutes
    PC_VERSION_NEW=$(cd $PC_DIR && git fetch -q && git describe --tags `git rev-list --tags --max-count=1`)
else
    PC_VERSION_NEW=$(cd $PC_DIR && git describe --tags `git rev-list --tags --max-count=1`)
fi

PC_VERSION_SUFFIX="-beta"
# name of the config file
PC_CONF_FILE="pro-cli.json"
# path to the local config file
PC_CONF="$WDIR/$PC_CONF_FILE"


# # # # # # # # # # # # # # # # # # # #
# output manipulation
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"
CLEAR_LINE="\r\033[K"


# # # # # # # # # # # # # # # # # # # #
# returns an attribute of the local config
get_conf() {
    if [ -f $PC_CONF ]; then
        echo $(cat $PC_CONF | jq -r ".$1")
    fi
}

PC_TYPE=$(get_conf 'type')
PC_ENV=$(get_conf 'env')


# # # # # # # # # # # # # # # # # # # #
# shows the help
help() {
    # path to local node_modules
    PC_NPM_CONFIG="$WDIR/src/package.json"
    # spaces until the commands descriptions starts
    SPACE="                      "

    printf "    ${BLUE}pro-cli ${BOLD}v${PC_VERSION}-beta${NORMAL}\n"
    printf "\n"
    printf "    help: project [command]\n"
    printf "\n"
    printf "    COMMANDS:\n"
    printf "        ${BLUE}self-update${NORMAL}${SPACE:11}Update pro-cli.\n"
    printf "        ${BLUE}init${NORMAL}${SPACE:4}Setup default project structure in the specified directory.\n"
    printf "        ${BLUE}install${NORMAL}${SPACE:7}Install application by executing the commands specified in ${BOLD}pro-cli.json${NORMAL}.\n"
    printf "        ${BLUE}update${NORMAL}${SPACE:6}Update application by executing the commands specified in ${BOLD}pro-cli.json${NORMAL}.\n"
    printf "        ${BLUE}config${NORMAL}${SPACE:6}Read and write config settings.${NORMAL}\n"
    printf "\n"

    # # # # # # # # # # # # # # # # # # # #
    # show docker commands help if local config file exists
    if [ -f "$WDIR/docker-compose.yml" ]; then
        printf "    DOCKER COMMANDS:\n"
        printf "        ${BLUE}start${NORMAL}${SPACE:5}Start the specified service. ${YELLOW}Created containers expected.${NORMAL}\n"
        printf "        ${BLUE}stop${NORMAL}${SPACE:4}Stop all or just the specified service.\n"
        printf "        ${BLUE}up${NORMAL}${SPACE:2}Start all docker containers and application.\n"
        printf "        ${BLUE}down${NORMAL}${SPACE:4}Stop and remove all docker containers. ${YELLOW}Removes mounted volumes${NORMAL}.\n"
        printf "        ${BLUE}compose${NORMAL}${SPACE:7}Run docker-compose commands.\n"
        printf "        ${BLUE}logs${NORMAL}${SPACE:4}Show logs of all or the specified service.\n"
        printf "        ${BLUE}status${NORMAL}${SPACE:6}List all service containers and show their status.\n"
        printf "        ${BLUE}top${NORMAL}${SPACE:3}Display a live stream of container(s) resource usage statistics.\n"
        printf "\n"
    fi

    # # # # # # # # # # # # # # # # # # # #
    # show PHP commands if the current project is of type laravel or PHP
    if [[ -f $PC_CONF && ( $PC_TYPE == "laravel" || $PC_TYPE == "php" )]]; then
        printf "    PHP COMMANDS:\n"
        printf "        ${BLUE}composer${NORMAL}${SPACE:8}Run composer commands.\n"
        printf "        ${BLUE}test${NORMAL}${SPACE:4}Run Unit Tests.\n"
        printf "\n"
    fi

    # # # # # # # # # # # # # # # # # # # #
    # show PHP commands if the current project is of type laravel
    if [ -f $PC_CONF ] && [[ $PC_TYPE == "laravel" ]]; then
        printf "    LARAVEL COMMANDS:\n"
        printf "        ${BLUE}artisan${NORMAL}${SPACE:7}Run artisan commands.\n"
        printf "        ${BLUE}tinker${NORMAL}${SPACE:6}Interact with your application.\n"
        printf "\n"
    fi

    # # # # # # # # # # # # # # # # # # # #
    # show npm commands help if package.json exists
    if [ -f $PC_NPM_CONFIG ]; then
        printf "    NODE COMMANDS:\n"
        printf "        ${BLUE}npm${NORMAL}${SPACE:3}Run npm commands.\n"
        printf "        ${BLUE}yarn${NORMAL}${SPACE:4}Run yarn commands.\n"
        printf "\n"
    fi

    # # # # # # # # # # # # # # # # # # # #
    # show custom commands help if the local config has scripts
    if [ -f "$WDIR/$PC_CONF_FILE" ]; then
        # fetch script keys
        COMMAND_KEYS=$(cat $WDIR/$PC_CONF_FILE | jq -crM '.scripts | keys[]')

        if [ ! -z "$COMMAND_KEYS" ]; then
            printf "    CUSTOM COMMANDS:\n"

            while read -r KEY; do
                IS_OBJECT=$(cat $WDIR/$PC_CONF_FILE | jq -crM --arg cmd "$KEY" 'if (.scripts[$cmd] | type == "object") then true else false end')
                DESCRIPTION=""

                # get the command by key selection
                if [ "true" == "$IS_OBJECT" ]; then
                    DESCRIPTION=$(cat $WDIR/$PC_CONF_FILE | jq -crM --arg cmd "$KEY" '.scripts[$cmd]["description"]')
                else
                    DESCRIPTION=$(cat $WDIR/$PC_CONF_FILE | jq -crM --arg cmd "$KEY" '.scripts[$cmd]')
                fi

                # string length
                COUNT=${#KEY}
                printf "        ${BLUE}${KEY}${NORMAL}${SPACE:$COUNT}${DESCRIPTION}\n"
            done <<< "$COMMAND_KEYS"
        fi
    fi
}

# # # # # # # # # # # # # # # # # # # #
# initialize a project
# project init [path] [--type=TYPE]
init_project() {
    local TYPE="laravel"
    # supported types
    local TYPES=("php laravel")
    local DIR=$1

    shift

    # check for available parameters 
    for i in "$@"; do
        case $i in -t=*|--type=*)
            # save type parameter if available
            TYPE="${i#*=}"
            shift
            ;;
        esac
    done

    # check if type is actually supported
    if [[ ! " ${TYPES[@]} " =~ " ${TYPE} " ]]; then
        printf "${RED}Unsupported project type!${NORMAL}\n"
        exit
    fi

    mkdir -p $DIR

    git clone -q https://github.com/chriha/pro-php.git $DIR
    rm -rf $DIR/.git $DIR/README.md

    # create local config from template and set project type
    cat $PC_DIR/$PC_CONF_FILE | jq --arg PROJECT_TYPE $TYPE '.type = $PROJECT_TYPE' > $DIR/$PC_CONF_FILE
}
