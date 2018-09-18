#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# show MySQL commands if the current project is of type laravel or PHP
if [ -f "$PROJECT_CONFIG" ]; then
    printf "MYSQL COMMANDS:\n"
    printf "    ${BLUE}query-logs${NORMAL}${HELP_SPACE:10}Manage query logs.\n"
fi
