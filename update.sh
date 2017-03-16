#!/usr/bin/env bash

printf "Updating pro-cli ...\n"

cd $PC_DIR && git fetch -q

if git checkout -q $(git describe --tags `git rev-list --tags --max-count=1`)
then
    printf "${GREEN}"
    printf '%s\n' ' ______   ______     ______     ______     __         __   '
    printf '%s\n' '/\  == \ /\  == \   /\  __ \   /\  ___\   /\ \       /\ \  '
    printf '%s\n' '\ \  _-/ \ \  __<   \ \ \/\ \  \ \ \____  \ \ \____  \ \ \ '
    printf '%s\n' ' \ \_\    \ \_\ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\'
    printf '%s\n' '  \/_/     \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/'
    printf "${NORMAL}\n"

    PC_VERSION=$( cd $PC_DIR && git describe --abbrev=0 --tags )

    printf "${BLUE}Yessss! pro-cli has been updated and is now on version ${BOLD}v${PC_VERSION}${NORMAL}\n"
else
    printf "${RED}There was an error updating. Try again later?${NORMAL}"
fi
