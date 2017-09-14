#!/usr/bin/env bash

PC_DIR="$HOME/.pro-cli"
PC_BIN_DIR="$HOME/.bin"
PC_SYSTEM=$(uname -s)

# # # # # # # # # # # # # # # # # # # #
# output manipulation
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

# # # # # # # # # # # # # # # # # # # #
# oh-my-zsh installed
if [ -f "$HOME/.zshrc" ]; then
    CLI_BASH_RC="$HOME/.zshrc"

# # # # # # # # # # # # # # # # # # # #
# mac OSX and .bash_profile
elif [ $PC_SYSTEM = 'Darwin' ] && [ -f "$HOME/.bash_profile" ]; then
    CLI_BASH_RC="$HOME/.bash_profile"

# # # # # # # # # # # # # # # # # # # #
# mac OSX and .profile
elif [ $PC_SYSTEM = 'Darwin' ] && [ -f "$HOME/.profile" ]; then
    CLI_BASH_RC="$HOME/.profile"

# # # # # # # # # # # # # # # # # # # #
# last try with the .bashrc
else
    CLI_BASH_RC="$HOME/.bashrc"
fi

# # # # # # # # # # # # # # # # # # # #
# couldn't find the bash resource, so abort
if [ -z "$CLI_BASH_RC" ]; then
    printf "${RED}Unable to find bash resource!${NORMAL}"
    exit
fi

printf "Installing pro-cli ....\n"

mkdir -p $PC_BIN_DIR

# # # # # # # # # # # # # # # # # # # #
# check if the .bin directory is already part of $PATH in the
# resource file and if not, add it!
grep -E 'export PATH=.*(\~\/|\$HOME\/)\.bin.*\$PATH' $CLI_BASH_RC > /dev/null || echo 'export PATH=~/.bin:$PATH' >> $CLI_BASH_RC

ln -sf $PC_DIR/project.sh $PC_BIN_DIR/project

printf "${GREEN}"
printf '%s\n' ' ______   ______     ______     ______     __         __   '
printf '%s\n' '/\  == \ /\  == \   /\  __ \   /\  ___\   /\ \       /\ \  '
printf '%s\n' '\ \  _-/ \ \  __<   \ \ \/\ \  \ \ \____  \ \ \____  \ \ \ '
printf '%s\n' ' \ \_\    \ \_\ \_\  \ \_____\  \ \_____\  \ \_____\  \ \_\'
printf '%s\n' '  \/_/     \/_/ /_/   \/_____/   \/_____/   \/_____/   \/_/'
printf "${NORMAL}\n"

# fetch latest version
PC_VERSION=$( cd $PC_DIR && git describe --tags `git rev-list --tags --max-count=1` )

printf "${BLUE}Yessss! pro-cli has been installed and is now on version ${BOLD}v${PC_VERSION}${NORMAL}.\n\n"
