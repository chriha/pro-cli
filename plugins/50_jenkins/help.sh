#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# show Jenkins commands if local config file exists
if [ -f "$PROJECT_CONFIG" ]; then
    printf "JENKINS COMMANDS:\n"
    printf "    ${BLUE}build${NORMAL}${HELP_SPACE:5}Start Jenkins build and print the console output (optional).\n"
fi
