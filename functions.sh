#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# shows the help
help() {
    # path to local node_modules
    PC_NPM_CONFIG="$WDIR/src/package.json"
    # spaces until the commands descriptions starts
    SPACE="                      "

    printf "${BLUE}pro-cli ${BOLD}v${PC_VERSION}-beta${NORMAL}\n"
    printf "help: project [command]\n\n"
    printf "COMMANDS:\n"
    printf "    ${BLUE}config${NORMAL}${SPACE:6}Read and write project configurations.${NORMAL}\n"
    printf "    ${BLUE}expose${NORMAL}${SPACE:6}Temporarily expose the application (ngrok required).\n"
    printf "    ${BLUE}init${NORMAL}${SPACE:4}Setup default project structure in the specified directory.\n"
    printf "    ${BLUE}list${NORMAL}${SPACE:4}List all projects.\n"
    printf "    ${BLUE}open${NORMAL}${SPACE:4}Open a project in a new tab.\n"
    printf "    ${BLUE}self-update${NORMAL}${SPACE:11}Update pro-cli manually.\n"
    printf "    ${BLUE}sync${NORMAL}${SPACE:4}Sync directory structure with pro-cli.\n"

    # # # # # # # # # # # # # # # # # # # #
    # show docker commands help if local config file exists
    if [ -f "$WDIR/docker-compose.yml" ]; then
        printf "DOCKER COMMANDS:\n"
        printf "    ${BLUE}compose${NORMAL}${SPACE:7}Run docker-compose commands.\n"
        printf "    ${BLUE}down${NORMAL}${SPACE:4}Stop ${YELLOW}and remove${NORMAL} all docker containers.\n"
        printf "    ${BLUE}exec${NORMAL}${SPACE:4}Run a command in the specified service.\n"
        printf "    ${BLUE}logs${NORMAL}${SPACE:4}Show logs of all or the specified service.\n"
        printf "    ${BLUE}restart${NORMAL}${SPACE:7}Shut down the environment and bring it up again.\n"
        printf "    ${BLUE}run${NORMAL}${SPACE:3}Run a service and execute following commands.\n"
        printf "    ${BLUE}start${NORMAL}${SPACE:5}Start the specified service. ${YELLOW}Created containers expected.${NORMAL}\n"
        printf "    ${BLUE}status${NORMAL}${SPACE:6}List all service containers and show their status.\n"
        printf "    ${BLUE}stop${NORMAL}${SPACE:4}Stop all or just the specified service.\n"
        printf "    ${BLUE}top${NORMAL}${SPACE:3}Display a live stream of container(s) resource usage statistics.\n"
        printf "    ${BLUE}up${NORMAL}${SPACE:2}Start all docker containers and application.\n"
    fi

    # # # # # # # # # # # # # # # # # # # #
    # show PHP commands if the current project is of type laravel or PHP
    if [[ -f $PC_CONF && ( $PC_TYPE == "laravel" || $PC_TYPE == "php" )]]; then
        printf "PHP COMMANDS:\n"
        printf "    ${BLUE}composer${NORMAL}${SPACE:8}Run composer commands.\n"
        printf "    ${BLUE}test${NORMAL}${SPACE:4}Run Unit Tests.\n"
    fi

    # # # # # # # # # # # # # # # # # # # #
    # show Laravel commands if the current project is of type laravel
    if [ -f $PC_CONF ] && [[ $PC_TYPE == "laravel" ]]; then
        printf "LARAVEL COMMANDS:\n"
        printf "    ${BLUE}artisan${NORMAL}${SPACE:7}Run artisan commands.\n"
        printf "    ${BLUE}tinker${NORMAL}${SPACE:6}Interact with your application.\n"
    fi

    # # # # # # # # # # # # # # # # # # # #
    # show npm commands help if package.json exists
    if [ -f $PC_NPM_CONFIG ]; then
        printf "NODE COMMANDS:\n"
        printf "    ${BLUE}npm${NORMAL}${SPACE:3}Run npm commands.\n"
        printf "    ${BLUE}yarn${NORMAL}${SPACE:4}Run yarn commands.\n"
    fi

    # # # # # # # # # # # # # # # # # # # #
    # show custom commands help
    if [ -f "$WDIR/$PC_CONF_FILE" ]; then
        # fetch script keys
        COMMAND_KEYS=$(cat $WDIR/$PC_CONF_FILE | jq -crM '.scripts | keys[]')

        if [ ! -z "$COMMAND_KEYS" ]; then
            printf "CUSTOM COMMANDS:\n"

            while read -r KEY; do
                DESCRIPTION=$(cat $WDIR/$PC_CONF_FILE | jq -crM --arg cmd "$KEY" '.scripts[$cmd]["description"]')

                # string length
                COUNT=${#KEY}
                printf "    ${BLUE}${KEY}${NORMAL}${SPACE:$COUNT}${DESCRIPTION}\n"
            done <<< "$COMMAND_KEYS"
        fi
    fi
}


# # # # # # # # # # # # # # # # # # # #
# initialize a project
# project init [path] [--type=TYPE]
init_project() {
    local TYPE="laravel"
    # supported types
    local TYPES=("php laravel nodejs")
    local DIR=$1

    shift

    # check for available parameters 
    for i in "$@"; do
        case $i in -t=*|--type=*)
            # save type parameter if available
            TYPE="${i#*=}"
            shift
            ;;
        esac
    done

    # check if type is actually supported
    if [[ ! " ${TYPES[@]} " =~ " ${TYPE} " ]]; then
        printf "${RED}Unsupported project type!${NORMAL}\n"
        exit
    fi

    mkdir -p $DIR

    cp -r "${PC_DIR}/environments/${TYPE}/" $DIR
    cp $DIR/.env.example $DIR/.env
}


# # # # # # # # # # # # # # # # # # # #
# synchronize project structure
# project sync
sync_structure() {
    if [ -d $PC_DIR/environments/ ] && [ ! -z "${PC_TYPE}" ]; then
        cp -ir "${PC_DIR}/environments/${PC_TYPE}/" $WDIR
    else
        printf "${RED}Unsupported project type!${NORMAL}\n"
    fi

    return 0
}


# # # # # # # # # # # # # # # # # # # #
# get unix timestamp from file
filemtime() {
    local SYSTEM=$(uname -s)

    local TIMESTAMP=0

    if [ "$SYSTEM" == "Darwin" ]; then
        if stat -f %y $1 &> /dev/null; then
            local CHANGED=$(stat -f %m $1)
        elif php -v &> /dev/null; then
            local CHANGED=$(php -r "echo filemtime('${1}');" 2> /dev/null)
        fi

        if [ ! -z "$CHANGED" ]; then
            TIMESTAMP=$(expr $(date +%s) - $(printf "%.0f" $CHANGED))
        fi
    else
        local CHANGED=$(stat -c %Y $1)

        TIMESTAMP=$(expr $(date +%s) - $(printf "%.0f" $CHANGED))
    fi

    echo $TIMESTAMP
}


# # # # # # # # # # # # # # # # # # # #
# check if any error occured
has_errors() {
    if [ ! -f $OUTPUT_FILE ] && [ ! -s $OUTPUT_FILE ]; then
        return 1
    fi

    if grep -qi 'error\|invalid' "$OUTPUT_FILE"; then
        printf "${RED}"
        cat $OUTPUT_FILE
        printf "${NORMAL}"
        return 0
    elif grep -qi 'warning' "$OUTPUT_FILE"; then
        printf "${YELLOW}"
        cat $OUTPUT_FILE
        printf "${NORMAL}"
        return 0
    fi

    return 1
}


# # # # # # # # # # # # # # # # # # # #
# reset error file
reset_output() {
    echo '' > $OUTPUT_FILE
}


# # # # # # # # # # # # # # # # # # # #
# reset asked file
reset_asked() {
    rm $ASKED_FILE
}


# # # # # # # # # # # # # # # # # # # #
# spinner
# (sleep 4) &
# spinner $1 "A nice text ..."
spinner() {
    local cl="\r\033[K"
    local pid=$1
    local spinnging=true
    local delay=0.05
    local spinstr="⠏⠛⠹⠼⠶⠧"

    printf "  "

    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local tmp=${spinstr#?}

        if [ -z "$2" ]; then
            printf "\b\b\b${tmp:0:1} "
        else
            printf "${cl}${tmp:0:1} ${2}"
        fi

        local spinstr=$tmp${spinstr%"$tmp"}
        sleep $delay
    done

    printf "${cl}"
}


# # # # # # # # # # # # # # # # # # # #
# open_project
open_project() {
    local CDTO="$1"
    local PROJECT_NAME="$2"

    case "$TERM_PROGRAM" in
        "iTerm.app")
            osascript &> /dev/null <<EOF
                tell application "iTerm"
                    tell current window
                        set newTab to (create tab with default profile)

                        tell newTab
                            tell current session
                                write text "cd \"$CDTO\""
                            end tell
                        end tell
                    end tell
                end tell
EOF
        ;;
        "Apple_Terminal")
            osascript &> /dev/null <<EOF
                tell application "System Events"
                    tell process "Terminal" to keystroke "t" using command down
                end tell

                tell application "Terminal"
                    activate
                    do script with command "cd \"$CDTO\"" in selected tab of the front window
                end tell
EOF
        ;;
        *)
            echo "Open project functionality only supported in Mac Terminal and iTerm"
        ;;
    esac
}

update_completions() {
    if [ ! -d "${PC_DIR}/completions" ]; then
        mkdir $PC_DIR/completions
    fi

    echo "#compdef project

    _project() {
        local -a commands
            commands=(
            'config:Read and write local config settings.'
            'expose:Temporarily expose the application (ngrok required).'
            'init:Setup default project structure in the specified directory.'
            'list:List all projects.'
            'open:Open a project in a new tab.'
            'self-update:Update pro-cli manually.'
            'sync:Sync directory structure with pro-cli.'
            'compose:Run docker-compose commands.'
            'down:Stop and remove all docker containers.'
            'logs:Show logs of all or the specified service.'
            'restart:Shut down the environment and bring it up again.'
            'run:Run a service and execute following commands.'
            'start:Start the specified service. Created containers expected.'
            'status:List all service containers and show their status.'
            'stop:Stop all or just the specified service.'
            'top:Display a live stream of container(s) resource usage statistics.'
            'up:Start all docker containers and application.'
            'composer:Run composer commands.'
            'test:Run Unit Tests.'
            'artisan:Run artisan commands.'
            'tinker:Interact with your application.'
            'npm:Run npm commands.'
            'yarn:Run yarn commands.'
        )

        if (( CURRENT == 2 )); then
            _describe -t commands 'commands' commands
        fi

        return 0
    }

    _project" > $PC_DIR/completions/_project
}
