#!/usr/bin/env bash

if ! jq --version &> /dev/null; then
    printf "${RED}jq not installed, but is required.${NORMAL}\n"
    exit
fi

BASE_DIR="$HOME/.pro-cli"
BASE_CONFIG="$BASE_DIR/config.json"

if [ -f "$BASE_DIR/.git/FETCH_HEAD" ]; then
    HEAD_FILE="$BASE_DIR/.git/FETCH_HEAD"
else
    HEAD_FILE="$BASE_DIR/.git/HEAD"
fi

# # # # # # # # # # # # # # # # # # # #
# output manipulation
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
YELLOW="$(tput setaf 3)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

printf "${GREEN}"
printf '%s\n' ' ______   ______     ______     ______     __         __   '
printf '%s\n' '/\  == \ /\  == \   /\  __ \   /\  ___\   /\ \       /\ \  '
printf '%s\n' '\ \  _-/ \ \  __<   \ \ \/\ \  \ \ \____  \ \ \____  \ \ \ '
printf '%s\n' ' \ \_\    \ \_\ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\'
printf '%s\n' '  \/_/     \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/'
printf "${NORMAL}\n"

# fetch latest version
VERSION=$( cd $BASE_DIR && git describe --tags `git rev-list --tags --max-count=1` )

if [ ! -f "$BASE_CONFIG" ]; then
    echo "{ \"projects\": {}, \"version\": \"${VERSION}\" }" | jq -M . > "$BASE_CONFIG"
fi

TIMESTAMP=$(unixtime_from_file "$HEAD_FILE")
JSON=$(cat "$BASE_CONFIG" | jq ".updated_at = ${TIMESTAMP}" | jq -M .)
store_config "$JSON"

printf "${BLUE}pro-cli ${BOLD}v${VERSION}${NORMAL} ${BLUE}has been installed${NORMAL}. "
printf "${YELLOW}However, you still have to add a symlink via:${NORMAL}\n"
printf "sudo ln -s $BASE_DIR/project.sh /usr/local/bin/project\n"
printf "${YELLOW}... and restart your current shell session to have the 'project' command available.${NORMAL}\n\n"
