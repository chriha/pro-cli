#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# show MySQL commands if the current project is of type laravel or PHP
if [ -f "$PROJECT_CONFIG" ]; then
    printf "API COMMANDS:\n"
    printf "    ${BLUE}aglio${NORMAL}${HELP_SPACE:5}Execute aglio.\n"
    printf "    ${BLUE}doc${NORMAL}${HELP_SPACE:3}Render and serve API documentation.\n"
    printf "    ${BLUE}lint${NORMAL}${HELP_SPACE:4}Validate your API blueprint.\n"
    printf "    ${BLUE}render${NORMAL}${HELP_SPACE:6}Render API blueprint.\n"
fi
