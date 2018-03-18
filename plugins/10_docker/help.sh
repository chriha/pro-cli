#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# show docker commands help if local config file exists
if [ -f "$WDIR/docker-compose.yml" ]; then
    printf "DOCKER COMMANDS:\n"
    printf "    ${BLUE}compose${NORMAL}${HELP_SPACE:7}Run docker-compose commands.\n"
    printf "    ${BLUE}down${NORMAL}${HELP_SPACE:4}Stop ${YELLOW}and remove${NORMAL} all docker containers.\n"
    printf "    ${BLUE}exec${NORMAL}${HELP_SPACE:4}Run a command in the specified service.\n"
    printf "    ${BLUE}logs${NORMAL}${HELP_SPACE:4}Show logs of all or the specified service.\n"
    printf "    ${BLUE}restart${NORMAL}${HELP_SPACE:7}Shut down the environment and bring it up again.\n"
    printf "    ${BLUE}run${NORMAL}${HELP_SPACE:3}Run a service and execute following commands.\n"
    printf "    ${BLUE}start${NORMAL}${HELP_SPACE:5}Start the specified service. ${YELLOW}Created containers expected.${NORMAL}\n"
    printf "    ${BLUE}status${NORMAL}${HELP_SPACE:6}List all service containers and show their status.\n"
    printf "    ${BLUE}stop${NORMAL}${HELP_SPACE:4}Stop all or just the specified service.\n"
    printf "    ${BLUE}top${NORMAL}${HELP_SPACE:3}Display a live stream of container(s) resource usage statistics.\n"
    printf "    ${BLUE}up${NORMAL}${HELP_SPACE:2}Start all docker containers and application.\n"
fi
