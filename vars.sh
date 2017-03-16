#!/usr/bin/env bash

PC_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PC_VERSION=$( cd $PC_DIR && git describe --abbrev=0 --tags )
PC_CONF_FILE="pro-cli.json"
PC_CONF="$WDIR/$PC_CONF_FILE"
PC_NODE="$WDIR/src/node_modules"

get_conf() {
    if [ -f $PC_CONF ]; then
        echo $(cat $PC_CONF | jq -r ".$1")
    fi
}

PC_TYPE=$(get_conf 'type')
PC_ENV=$(get_conf 'env')

RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"
CLEAR_LINE="\r\033[K"

help() {
    printf "    ${BLUE}pro-cli ${BOLD}v${PC_VERSION}${NORMAL}\n"
    printf "\n"
    printf "    help: project [command]\n"
    printf "\n"
    printf "    COMMANDS:\n"
    printf "        ${BLUE}self-update${NORMAL}         Update pro-cli.\n"
    printf "        ${BLUE}init${NORMAL}                Setup default project structure.\n"
    printf "        ${BLUE}install${NORMAL}             Install application by executing the commands specified in ${BOLD}pro-cli.json${NORMAL}.\n"
    printf "        ${BLUE}update${NORMAL}              Update project structure and docker images. ${YELLOW}Will overwrite pro-cli project files.${NORMAL}\n"
    printf "        ${BLUE}run${NORMAL}                 Run a script that is specified in ${BOLD}pro-cli.json${NORMAL}.\n"
    printf "\n"

    if [ -f $PC_CONF ]; then
        printf "    DOCKER COMMANDS:\n"
        printf "        ${BLUE}start${NORMAL}               Start application.\n"
        printf "        ${BLUE}stop${NORMAL}                Stop application.\n"
        printf "        ${BLUE}up${NORMAL}                  Start all docker containers and application.\n"
        printf "        ${BLUE}down${NORMAL}                Stop and remove all docker containers. ${YELLOW}Removes mounted volumes${NORMAL}.\n"
        printf "        ${BLUE}compose${NORMAL}             Run docker-compose commands.\n"
        printf "        ${BLUE}logs${NORMAL}                Show application logs.\n"
        printf "        ${BLUE}status${NORMAL}              List application containers and show the status.\n"
        printf "\n"
    fi

    if [[ -f $PC_CONF && ( $PC_TYPE == "laravel" || $PC_TYPE == "php" )]]; then
        printf "    PHP COMMANDS:\n"
        printf "        ${BLUE}composer${NORMAL}            Run composer commands.\n"
        printf "        ${BLUE}test${NORMAL}                Run Unit Tests.\n"
        printf "\n"
    fi

    if [ -f $PC_CONF ] && [ $PC_TYPE == "laravel" ]; then
        printf "    LARAVEL COMMANDS:\n"
        printf "        ${BLUE}artisan${NORMAL}             Run artisan commands.\n"
        printf "        ${BLUE}tinker${NORMAL}              Interact with your application.\n"
        printf "\n"
    fi

    if [ -d $PC_NODE ]; then
        printf "    NODE COMMANDS:\n"
        printf "        ${BLUE}npm${NORMAL}                 Run npm commands.\n"
        printf "        ${BLUE}yarn${NORMAL}                Run yarn commands.\n"
        printf "\n"
    fi
}

init_project() {
    local TYPE="laravel"
    local TYPES=("php laravel")
    local DIR=$1

    shift

    for i in "$@"
    do
        case $i in -t=*|--type=*)
            TYPE="${i#*=}"
            shift
            ;;
        esac
    done

    if [[ ! " ${TYPES[@]} " =~ " ${TYPE} " ]]; then
        printf "${RED}Unsupported project type!${NORMAL}\n"
        exit
    fi

    if [ ! -d "$DIR" ]; then
        mkdir -p $DIR
    fi

    git clone -q https://github.com/chriha/pro-php.git $DIR
    rm -rf $DIR/.git $DIR/README.md

    cat $PC_DIR | jq '.type = '"$TYPE"'' > $DIR/$PC_CONF_FILE
}
