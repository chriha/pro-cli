#!/usr/bin/env bash

printf "Updating pro-cli ..."

PC_VERSION_OLD=$(cd $PC_DIR && git describe --tags `git rev-list --tags --max-count=1`)
PC_VERSION_NEW=$(cd $PC_DIR && git fetch -q && git describe --tags `git rev-list --tags --max-count=1`)

# # # # # # # # # # # # # # # # # # # #
# latest version already installed
if [ "$PC_VERSION_OLD" == "$PC_VERSION_NEW" ]; then
    printf "${CLEAR_LINE}${GREEN}You have the latest version: ${BOLD}${PC_VERSION_OLD}-beta${NORMAL}\n"
    exit
fi

cd $PC_DIR

# # # # # # # # # # # # # # # # # # # #
# checkout the latest tag
if git checkout -q $(git describe --tags `git rev-list --tags --max-count=1`)
then
    printf "\n"
    printf "${GREEN}"
    printf '%s\n' ' ______   ______     ______     ______     __         __   '
    printf '%s\n' '/\  == \ /\  == \   /\  __ \   /\  ___\   /\ \       /\ \  '
    printf '%s\n' '\ \  _-/ \ \  __<   \ \ \/\ \  \ \ \____  \ \ \____  \ \ \ '
    printf '%s\n' ' \ \_\    \ \_\ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\'
    printf '%s\n' '  \/_/     \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/'
    printf "${NORMAL}\n"

    printf "${BLUE}Yessss! pro-cli has been updated and is now on version ${BOLD}v${PC_VERSION_NEW}-beta${NORMAL}\n"
else
    printf "\n${RED}There was an error while updating to the latest version. Try again later.${NORMAL}"
fi
