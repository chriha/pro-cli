#!/usr/bin/env bash

PC_DIR="$HOME/.pro-cli"
PC_BIN_DIR="$HOME/.bin"
PC_SYSTEM=$(uname -s)

if [ -f "$HOME/.zshrc" ]; then
    CLI_BASH_RC="$HOME/.zshrc"
elif [ $PC_SYSTEM = 'Darwin' ] && [ -f "$HOME/.bash_profile" ]; then
    CLI_BASH_RC="$HOME/.bash_profile"
elif [ $PC_SYSTEM = 'Darwin' ] && [ -f "$HOME/.bashrc" ]; then
    CLI_BASH_RC="$HOME/.bash_profile"
else
    CLI_BASH_RC="$HOME/.bashrc"
fi

printf 'Installing pro-cli ....\n'

if [ ! -d "$PC_BIN_DIR" ]; then
    mkdir $HOME/.bin
fi

grep -E 'export PATH=.*(\~\/|\$HOME\/)\.bin.*\$PATH' $CLI_BASH_RC > /dev/null || echo 'export PATH=~/.bin:$PATH' >> $CLI_BASH_RC

ln -sf $PC_DIR/project.sh $PC_BIN_DIR/project

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

PC_VERSION=$( cd $PC_DIR && git describe --tags `git rev-list --tags --max-count=1` )

printf "${BLUE}Yessss! pro-cli has been installed and is now on version ${BOLD}v${PC_VERSION}${NORMAL}.\n\n"

