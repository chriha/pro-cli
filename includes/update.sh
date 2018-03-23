#!/usr/bin/env bash

update_completions

printf "\n"

VERSION_OLD=$(cd "$BASE_DIR" && git describe --tags)
VERSION_NEW=$(cd "$BASE_DIR" && git fetch -q && git describe --tags `git rev-list --tags --max-count=1`)
TIMESTAMP=$(unixtime_from_file "$HEAD_FILE")

# latest version already installed
if [ "$VERSION_OLD" == "$VERSION_NEW" ]; then
    printf "${CLEAR_LINE}${GREEN}You have the latest version: ${BOLD}${VERSION_OLD}${NORMAL}\n"
    JSON=$(cat "$BASE_CONFIG" | jq ".version = \"${VERSION_OLD}\"" | jq ".updated_at = ${TIMESTAMP}" | jq -M .)
    store_config "$JSON"
    exit
fi

cd "$BASE_DIR"

# # # # # # # # # # # # # # # # # # # #
# checkout the latest tag
(sleep 1 && git checkout -q $VERSION_NEW) &
spinner $! "Updating ..."

CURRENT=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))

if [ "$VERSION_NEW" == "$CURRENT" ]; then
    reset_asked

    JSON=$(cat "$BASE_CONFIG" | jq ".version = \"${VERSION_NEW}\"" | jq ".updated_at = ${TIMESTAMP}" | jq -M .)
    store_config "$JSON"

    printf "${GREEN}"
    printf '%s\n' ' ______   ______     ______     ______     __         __   '
    printf '%s\n' '/\  == \ /\  == \   /\  __ \   /\  ___\   /\ \       /\ \  '
    printf '%s\n' '\ \  _-/ \ \  __<   \ \ \/\ \  \ \ \____  \ \ \____  \ \ \ '
    printf '%s\n' ' \ \_\    \ \_\ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\'
    printf '%s\n' '  \/_/     \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/'
    printf "${NORMAL}\n"

    printf "${BLUE}Yessss! pro-cli has been updated and is now on version ${BOLD}v${VERSION_NEW}${NORMAL}\n"
    CHANGES=$(git log --pretty=oneline --abbrev-commit $VERSION_OLD..$VERSION_NEW)

    printf "\n"
    printf "${YELLOW}Changes since your last update:\n"
    echo "--------------------------------------------------${NORMAL}"
    echo -e "$CHANGES" | sed 's/^.\{8\}\(.*\)/- \1/g'

else
    printf "\n${RED}There was an error while updating to the latest version. Try again later.${NORMAL}\n"
fi
