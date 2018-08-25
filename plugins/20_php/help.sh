#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# show PHP commands if the current project is of type laravel or PHP
if [[ -f "$PROJECT_CONFIG" && ( "$PROJECT_TYPE" == "laravel" || "$PROJECT_TYPE" == "php" )]]; then
    printf "PHP COMMANDS:\n"
    printf "    ${BLUE}composer${NORMAL}${HELP_SPACE:8}Run composer commands.\n"
    printf "    ${BLUE}php${NORMAL}${HELP_SPACE:3}Run PHP commands.\n"
    printf "    ${BLUE}test${NORMAL}${HELP_SPACE:4}Run Unit Tests.\n"
    printf "    ${BLUE}xdebug${NORMAL}${HELP_SPACE:6}Enable / disable Xdebug.\n"
fi
