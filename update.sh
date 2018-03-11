#!/usr/bin/env bash

update_completions

PC_VERSION_OLD=$(cd $PC_DIR && git describe --tags)
PC_VERSION_NEW=$(cd $PC_DIR && git fetch -q && git describe --tags `git rev-list --tags --max-count=1`)

# # # # # # # # # # # # # # # # # # # #
# latest version already installed
if [ "$PC_VERSION_OLD" == "$PC_VERSION_NEW" ]; then
    printf "${CLEAR_LINE}${GREEN}You have the latest version: ${BOLD}${PC_VERSION_OLD}${NORMAL}\n"
    exit
fi

cd $PC_DIR

# # # # # # # # # # # # # # # # # # # #
# checkout the latest tag
(sleep 2 && git checkout -q $PC_VERSION_NEW) &
spinner $! "Updating ..."

current=$(git describe --exact-match --tags $(git log -n1 --pretty='%h'))

if [ "$PC_VERSION_NEW" == "$current" ]; then
    reset_asked
    printf "${GREEN}"
    printf '%s\n' ' ______   ______     ______     ______     __         __   '
    printf '%s\n' '/\  == \ /\  == \   /\  __ \   /\  ___\   /\ \       /\ \  '
    printf '%s\n' '\ \  _-/ \ \  __<   \ \ \/\ \  \ \ \____  \ \ \____  \ \ \ '
    printf '%s\n' ' \ \_\    \ \_\ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\'
    printf '%s\n' '  \/_/     \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/'
    printf "${NORMAL}\n"

    printf "${BLUE}Yessss! pro-cli has been updated and is now on version ${BOLD}v${PC_VERSION_NEW}${NORMAL}\n"
    PC_CHANGES=$(git log --pretty=oneline --abbrev-commit $PC_VERSION_OLD..$PC_VERSION_NEW)

    printf "\n"
    printf "${YELLOW}Changes since your last update:\n"
    echo "--------------------------------------------------${NORMAL}"
    echo -e "$PC_CHANGES" | sed 's/^.\{8\}\(.*\)/- \1/g'

else
    printf "\n${RED}There was an error while updating to the latest version. Try again later.${NORMAL}\n"
fi
