#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute npm commands
if [ "$1" == "npm" ]; then
    if ( needs_help $@ ); then
        printf "${YELLOW}usage:${NORMAL} project npm [command]\n\n"
        printf "OPTIONS:\n"
        printf "    ${BLUE}--auth='user:password'${NORMAL}${HELP_SPACE:22}Secure the application with basic auth.${NORMAL}\n"
        exit 1
    fi

    shift
    $RUN $DOCKER_USER_PARAM -v "$(pwd)/temp/npm":"/.npm" node npm $@
    exit

# # # # # # # # # # # # # # # # # # # #
# execute yarn commands
elif [ "$1" == "yarn" ]; then
    shift
    $RUN -v "$(pwd)/temp/yarn":"/.yarn" yarn yarn $@
    exit
fi
