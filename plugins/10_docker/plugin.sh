#!/usr/bin/env bash

check_for_existing_volumes() {
    $IS_MAC && return 0

    if ! ruby -v &> /dev/null; then
        printf "${RED}To convert YAML to JSON, ruby needs to be installed.${NORMAL}\n" && exit 1
    fi

    local VOLUMES=$(cat "$COMPOSE_FILE" | yaml2json | jq -r '.services | map(.volumes) | add | .[]' | awk '!seen[$0]++')

    while read line; do
        VOLUME="${line%%:*}"

        [ -f "$VOLUME" ] || [ -d "$VOLUME" ] && continue

        # well, we don't know if it really should be a file
        mkdir -p "$WDIR/$VOLUME"
    done <<< "$VOLUMES"
}

COMPOSE_ENV=""
TTY=""

# use docker-compose file according to env and if it exists
if [ ! -z "$PROJECT_ENVIRONMENT" ] && [ -f "./docker-compose.${PROJECT_ENVIRONMENT}.yml" ]; then
    readonly COMPOSE_ENV=".${PROJECT_ENVIRONMENT}"
fi

# # # # # # # # # # # # # # # # # # # #
# disable pseudo-TTY allocation for CI (Jenkins)
if [ ! -z "$BUILD_NUMBER" ]; then
    TTY="-T"
fi

if $IS_MAC; then
    DOCKER_USER_PARAM=""
else
    DOCKER_USER_PARAM="-u $USER_ID:$USER_GROUP_ID"
fi

readonly COMPOSE_FILE="docker-compose$COMPOSE_ENV.yml"
readonly COMPOSE="docker-compose -f $COMPOSE_FILE"

# # # # # # # # # # # # # # # # # # # #
# set default workdir only if none is given
if [[ $* == *\ -w* ]]; then
    readonly RUN="$COMPOSE run --rm $TTY"
else
    readonly RUN="$COMPOSE run --rm $TTY -w /var/www"
fi


# # # # # # # # # # # # # # # # # # # #
# show all containers status
if [ "$1" == "status" ]; then
    shift
    $COMPOSE ps $@
    exit

elif [ "$1" == "top" ]; then
    $COMPOSE ps | grep 'Up\|Exit' | awk '{print $1}' | tr "\\n" " " | xargs docker stats --all --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
    exit

# # # # # # # # # # # # # # # # # # # #
# create and start all or specific containers
elif [ "$1" == "up" ]; then
    ! $IS_MAC && check_for_existing_volumes
    check_ports
    shift

    ( $COMPOSE up -d $@ ) &> $OUTPUT_FILE &
    spinner $! "${YELLOW}Starting containers ... ${NORMAL}"
    has_errors || printf "${YELLOW}Starting containers ... ${NORMAL}${GREEN}done${NORMAL}\n" && exit

# # # # # # # # # # # # # # # # # # # #
# start all or specific containers
elif [ "$1" == "start" ]; then
    ! $IS_MAC && check_for_existing_volumes
    check_ports
    shift

    ( $COMPOSE start $@ ) &> $OUTPUT_FILE &
    spinner $! "${YELLOW}Starting containers ... ${NORMAL}"
    has_errors || printf "${YELLOW}Starting containers ... ${NORMAL}${GREEN}done${NORMAL}\n" && exit

# # # # # # # # # # # # # # # # # # # #
# stop all or specific containers
elif [ "$1" == "stop" ]; then
    shift
    ( $COMPOSE stop $@ ) &> $OUTPUT_FILE &
    spinner $! "${YELLOW}Stopping containers ... ${NORMAL}"
    has_errors || printf "${YELLOW}Stopping containers ... ${NORMAL}${GREEN}done${NORMAL}\n" && exit

# # # # # # # # # # # # # # # # # # # #
# stop and destroy all containers
elif [ "$1" == "down" ]; then
    ( $COMPOSE down ) &> $OUTPUT_FILE &
    spinner $! "${YELLOW}Removing containers ... ${NORMAL}"
    has_errors || printf "${YELLOW}Removing containers ... ${NORMAL}${GREEN}done${NORMAL}\n" && exit

# # # # # # # # # # # # # # # # # # # #
# restart by using down & up commands
elif [ "$1" == "restart" ]; then
    shift
    project down && project up $@
    exit

# # # # # # # # # # # # # # # # # # # #
# run docker-compose commands
elif [ "$1" == "compose" ]; then
    shift
    $COMPOSE $@
    exit

# # # # # # # # # # # # # # # # # # # #
# run a command in the specified container
elif [ "$1" == "exec" ]; then
    shift

    [ -z "$1" ] && printf "${RED}No service specified.${NORMAL}\n"

    $COMPOSE exec $@
    exit

# # # # # # # # # # # # # # # # # # # #
# run a service and execute further commands
elif [ "$1" == "run" ]; then
    shift
    $RUN $DOCKER_USER_PARAM $@
    exit

# # # # # # # # # # # # # # # # # # # #
# show logs of all or specific containers
elif [ "$1" == "logs" ]; then
    shift
    $COMPOSE logs $@
    exit
fi
