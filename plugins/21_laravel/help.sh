#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# show Laravel commands if the current project is of type laravel
if [ -f "$PROJECT_CONFIG" ] && [ "$PROJECT_TYPE" == "laravel" ]; then
    printf "LARAVEL COMMANDS:\n"
    printf "    ${BLUE}artisan${NORMAL}${HELP_SPACE:7}Run artisan commands.\n"
    printf "    ${BLUE}echo${NORMAL}${HELP_SPACE:4}Execute commands for laravel-echo-server.\n"
    printf "    ${BLUE}tinker${NORMAL}${HELP_SPACE:6}Interact with your application.\n"
fi
