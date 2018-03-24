#!/usr/bin/env bash

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

readonly COMPOSE="docker-compose -f docker-compose$COMPOSE_ENV.yml"
readonly RUN="$COMPOSE run --rm $TTY -w /var/www"

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
    check_ports
    shift

    ( $COMPOSE up -d $@ ) &> $OUTPUT_FILE &
    spinner $! "Starting containers ... "
    has_errors || printf "${GREEN}Containers started${NORMAL}\n" && exit

# # # # # # # # # # # # # # # # # # # #
# start all or specific containers
elif [ "$1" == "start" ]; then
    check_ports
    shift

    ( $COMPOSE start $@ ) &> $OUTPUT_FILE &
    spinner $! "Starting containers ... "
    has_errors || printf "${GREEN}Containers started${NORMAL}\n" && exit

# # # # # # # # # # # # # # # # # # # #
# stop all or specific containers
elif [ "$1" == "stop" ]; then
    shift
    ( $COMPOSE stop $@ ) &> $OUTPUT_FILE &
    spinner $! "Stopping containers ... "
    has_errors || printf "${GREEN}Containers stopped${NORMAL}\n" && exit

# # # # # # # # # # # # # # # # # # # #
# stop and destroy all containers
elif [ "$1" == "down" ]; then
    ( $COMPOSE down ) &> $OUTPUT_FILE &
    spinner $! "Shutting down containers ... "
    has_errors || printf "${GREEN}Containers stopped and removed${NORMAL}\n" && exit

# # # # # # # # # # # # # # # # # # # #
# restart by using down & up commands
elif [ "$1" == "restart" ]; then
    project down && project up
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
    $RUN $@
    exit

# # # # # # # # # # # # # # # # # # # #
# show logs of all or specific containers
elif [ "$1" == "logs" ]; then
    shift
    $COMPOSE logs $@
    exit
fi
