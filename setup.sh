#!/usr/bin/env bash

PC_DIR="$HOME/.pro-cli"

# # # # # # # # # # # # # # # # # # # #
# output manipulation
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
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
PC_VERSION=$( cd $PC_DIR && git describe --tags `git rev-list --tags --max-count=1` )

printf "${BLUE}pro-cli ${BOLD}v${PC_VERSION}${NORMAL} ${BLUE}has been installed${NORMAL}. "
printf "${YELLOW}However, you still have to add a symlink via:${NORMAL}\n"
printf "sudo ln -s $PC_DIR/project.sh /usr/local/bin/project\n"
printf "${YELLOW}... and restart your current shell session to have the 'project' command available.${NORMAL}\n\n"
