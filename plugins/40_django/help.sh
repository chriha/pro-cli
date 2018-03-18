#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# show PHP commands if the current project is of type laravel or PHP
if [[ -f "$PROJECT_CONFIG" && ( "$PROJECT_TYPE" == "django" || "$PROJECT_TYPE" == "python" )]]; then
    printf "DJANGO COMMANDS:\n"
    printf "    ${BLUE}python${NORMAL}${HELP_SPACE:6}Run python commands.\n"
    printf "    ${BLUE}django${NORMAL}${HELP_SPACE:6}Run application specific django commands.\n"
    printf "    ${BLUE}django-admin${NORMAL}${HELP_SPACE:12}Run django-admin commands.\n"
fi
