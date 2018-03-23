#!/usr/bin/env bash

# BASE_DIR is set in project.sh
. "${BASE_DIR}/includes/functions.sh"

USER_ID=$(id -u)
USER_GROUP_ID=$(id -g)
SYSTEM=$(uname -s)
IS_MAC=$([ "$SYSTEM" == "Darwin" ] && echo true)
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
BASE_CONFIG_JSON=$([ -f "$BASE_CONFIG" ] && cat "$BASE_CONFIG" || echo -n "")
OUTPUT_FILE="$BASE_DIR/output.log"
ASKED_FILE="$BASE_DIR/asked"
HELP_SPACE="                          "

# create base config if it doesn't exist
if [ ! -f "$BASE_CONFIG" ] || [ -z "$BASE_CONFIG_JSON" ]; then
    VERSION=$(cd "$BASE_DIR" && git describe --tags)
    store_config "$(echo "{ \"projects\": {}, \"version\": \"$VERSION\" }" | jq -c .)"
else
    VERSION=$([ -f "$BASE_CONFIG" ] && cat "$BASE_CONFIG" | jq -r '.version | select(.!=null)')
    VERSION=${VERSION:=$(cd "$BASE_DIR" && git describe --tags)}

    store_config "$(echo $BASE_CONFIG_JSON | jq ".version = \"${VERSION}\"" | jq -c .)"
fi

# set head file to check for latest fetch
if [ -f "$BASE_DIR/.git/FETCH_HEAD" ]; then
    HEAD_FILE="$BASE_DIR/.git/FETCH_HEAD"
else
    HEAD_FILE="$BASE_DIR/.git/HEAD"
fi

UPDATED_AT=$(echo "$BASE_CONFIG_JSON" | jq -r ".updated_at | select(.!=null)")

if [ ! -z "$UPDATED_AT" ]; then
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
    store_config "$(echo "$BASE_CONFIG_JSON" | jq ".updated_at = ${TIMESTAMP}")"
else
    VERSION_NEW=$VERSION
fi


# # # # # # # # # # # # # # # # # # # # # # #
# INITIALIZE LOCAL PROJECT
# to enable pro-cli in the project, try to fetch the working dir via Git
if git status &> /dev/null; then
    WDIR=$(git rev-parse --show-toplevel)
    cd "$WDIR"
fi

WDIR=${WDIR:=$(pwd)}

PROJECT_CONFIG="$WDIR/pro-cli.json"
PROJECT_CONFIG_JSON="$([ -f "$PROJECT_CONFIG" ] && cat "$PROJECT_CONFIG")"
PROJECT_NAME=${PWD##*/}
PROJECT_TYPE=false
PROJECT_ENVIRONMENT=false

if [ ! -z "$PROJECT_CONFIG_JSON" ]; then
    PROJECT_TYPE=$(echo "$PROJECT_CONFIG_JSON" | jq -r '.type')
    PROJECT_ENVIRONMENT=$(echo "$PROJECT_CONFIG_JSON" | jq -r '.env')
fi

PROJECT_EXISTS=$(echo "$BASE_CONFIG_JSON" | jq --arg dir "$PROJECT_NAME" '.projects | has("$dir")')

if [ "$PROJECT_EXISTS" == "false" ]; then
    store_config "$(echo "$BASE_CONFIG_JSON" | jq --arg project "$PROJECT_NAME" --arg dir "$WDIR" '.projects[$project] = $dir' | jq -c .)"
fi

reset_output
