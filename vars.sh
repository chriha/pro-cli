#!/usr/bin/env bash

. $PC_DIR/functions.sh

# # # # # # # # # # # # # # # # # # # #
# to enable pro-cli in the project, try to
# fetch the working dir via Git
if git status &> /dev/null; then
    WDIR=$(git rev-parse --show-toplevel)
    cd $WDIR
else
    WDIR=$(pwd)
fi

PC_USER_ID=$(id -u)
PC_USER_GROUP_ID=$(id -g)
PC_SYSTEM=$(uname -s)

# current pro-cli version
PC_VERSION=$(cd $PC_DIR && git describe --tags)

if [ -f "$PC_DIR/.git/FETCH_HEAD" ]; then
    PC_HEAD_FILE="$PC_DIR/.git/FETCH_HEAD"
else
    PC_HEAD_FILE="$PC_DIR/.git/HEAD"
fi

PC_LATEST_FETCH=$(filemtime $PC_HEAD_FILE)

# check for new version
if [ $PC_LATEST_FETCH != 0 ] && [ $PC_LATEST_FETCH -gt 43200 ]; then
    # only fetch every 12 hours
    PC_VERSION_NEW=$(cd $PC_DIR && git fetch -q && git describe --tags `git rev-list --tags --max-count=1`)
elif [ $PC_LATEST_FETCH != 0 ]; then
    PC_VERSION_NEW=$(cd $PC_DIR && git describe --tags `git rev-list --tags --max-count=1`)
fi

PC_VERSION_SUFFIX="-beta"
# name of the config file
PC_CONF_FILE="pro-cli.json"
# path to the local config file
PC_BASE_CONF="$PC_DIR/config.json"
PC_CONF="$WDIR/$PC_CONF_FILE"
OUTPUT_FILE=$PC_DIR/output.log
ASKED_FILE=$PC_DIR/asked
PC_PROJECT_NAME=${PWD##*/}
PC_HELP_SPACE="                          "


# create base config if it doesn't exist
if [ ! -f "$PC_BASE_CONF" ]; then
    echo '{ "projects": {} }' | jq . > $PC_BASE_CONF
fi

PC_PROJECT_EXISTS=$(cat $PC_BASE_CONF | jq --arg dir "$PC_PROJECT_NAME" '.projects | has("$dir")')

if [ -f "$PC_CONF" ] && [ "$PC_PROJECT_EXISTS" == "false" ]; then
    # JQ_PATH=".projects[\"${PC_PROJECT_NAME}]"

    PC_JSON=$(cat $PC_BASE_CONF | jq --arg project $PC_PROJECT_NAME --arg dir $WDIR '.projects[$project] = $dir' | jq -M .)

    if [ ! -z "$PC_JSON" ]; then
        printf '%s' "$PC_JSON" > $PC_BASE_CONF
    fi
fi

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
