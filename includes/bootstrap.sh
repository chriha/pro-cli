#!/usr/bin/env bash

# BASE_DIR is set in project.sh
. "${BASE_DIR}/includes/functions.sh"

USER_ID=$(id -u)
USER_GROUP_ID=$(id -g)
SYSTEM=$(uname -s)
# output manipulation
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"
CLEAR_LINE="\r\033[K"

# # # # # # # # # # # # # # # # # # # # # # #
# INITIALIZE PRO-CLI
BASE_CONFIG="$BASE_DIR/config.json"
OUTPUT_FILE="$BASE_DIR/output.log"
ASKED_FILE="$BASE_DIR/asked"
HELP_SPACE="                          "

# create base config if it doesn't exist
if [ ! -f "$BASE_CONFIG" ]; then
    VERSION=$(cd "$BASE_DIR" && git describe --tags)
    echo "{ \"projects\": {}, \"version\": \"$VERSION\" }" | jq -M . > "$BASE_CONFIG"
else
    VERSION=$(cat "$BASE_CONFIG" | jq -r ".version")

    # version not available, so set it
    if [ "$VERSION" == "null" ]; then
        VERSION=$(cd "$BASE_DIR" && git describe --tags)
        cat "$BASE_CONFIG" | jq ".version = \"${VERSION}\"" | jq -M . > "$BASE_CONFIG"
    fi
fi

# set head file to check for latest fetch
if [ -f "$BASE_DIR/.git/FETCH_HEAD" ]; then
    HEAD_FILE="$BASE_DIR/.git/FETCH_HEAD"
else
    HEAD_FILE="$BASE_DIR/.git/HEAD"
fi

UPDATED_AT=$(cat "$BASE_CONFIG" | jq -r ".updated_at")

if [ "$UPDATED_AT" != "null" ]; then
    LATEST_FETCH=$(filemtime $UPDATED_AT)
else
    LATEST_FETCH=9999999
fi

# check for new version, but fetch only every 12 hours
if [ $LATEST_FETCH != 0 ] && [ $LATEST_FETCH -gt 43200 ]; then
    VERSION_NEW=$(cd "$BASE_DIR" && git fetch -q && git describe --tags `git rev-list --tags --max-count=1`)
    # get unix timestamp of HEAD file
    TIMESTAMP=$(unixtime_from_file "$HEAD_FILE")
    # ... and store the timestamp in the config
    JSON=$(cat "$BASE_CONFIG" | jq ".updated_at = ${TIMESTAMP}")
    store_config "$JSON"
else
    VERSION_NEW=$VERSION
fi


# # # # # # # # # # # # # # # # # # # # # # #
# INITIALIZE LOCAL PROJECT
# to enable pro-cli in the project, try to fetch the working dir via Git
if git status &> /dev/null; then
    WDIR=$(git rev-parse --show-toplevel)
    cd "$WDIR"
else
    WDIR=$(pwd)
fi

PROJECT_CONFIG="$WDIR/pro-cli.json"
PROJECT_NAME=${PWD##*/}
PROJECT_TYPE=false
PROJECT_ENVIRONMENT=false

if [ -f "$PROJECT_CONFIG" ]; then
    PROJECT_TYPE=$(cat "$PROJECT_CONFIG" | jq -r '.type')
    PROJECT_ENVIRONMENT=$(cat "$PROJECT_CONFIG" | jq -r '.env')
fi

PROJECT_EXISTS=$(cat "$BASE_CONFIG" | jq --arg dir "$PROJECT_NAME" '.projects | has("$dir")')

if [ "$PROJECT_EXISTS" == "false" ]; then
    JSON=$(cat "$BASE_CONFIG" | jq --arg project "$PROJECT_NAME" --arg dir "$WDIR" '.projects[$project] = $dir' | jq -M .)
    store_config "$JSON"
fi

reset_output
