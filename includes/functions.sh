#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# shows the help
help() {
    printf "${BLUE}pro-cli ${BOLD}v${VERSION}${NORMAL}\n"
    printf "help: project [command]\n\n"
    printf "COMMANDS:\n"
    if [ -f "$PROJECT_CONFIG" ]; then
        printf "    ${BLUE}config${NORMAL}${HELP_SPACE:6}Read and write project configurations.${NORMAL}\n"
        printf "    ${BLUE}init${NORMAL}${HELP_SPACE:4}Setup default project structure in the specified directory.\n"
        printf "    ${BLUE}list${NORMAL}${HELP_SPACE:4}List all projects.\n"
        printf "    ${BLUE}open${NORMAL}${HELP_SPACE:4}Open a project in a new tab.\n"
        printf "    ${BLUE}plugin${NORMAL}${HELP_SPACE:6}Install, uninstall, update and list plugins.\n"
        printf "    ${BLUE}self-update${NORMAL}${HELP_SPACE:11}Update pro-cli manually.\n"
        printf "    ${BLUE}sync${NORMAL}${HELP_SPACE:4}Sync directory structure with pro-cli.\n"
    else
        printf "    ${BLUE}config${NORMAL}${HELP_SPACE:6}Read and write project configurations.${NORMAL}\n"
        printf "    ${BLUE}init${NORMAL}${HELP_SPACE:4}Setup default project structure in the specified directory.\n"
        printf "    ${BLUE}list${NORMAL}${HELP_SPACE:4}List all projects.\n"
        printf "    ${BLUE}open${NORMAL}${HELP_SPACE:4}Open a project in a new tab.\n"
        printf "    ${BLUE}plugin${NORMAL}${HELP_SPACE:5}Install, uninstall, update and list plugins.\n"
        printf "    ${BLUE}self-update${NORMAL}${HELP_SPACE:11}Update pro-cli manually.\n"
    fi

    # # # # # # # # # # # # # # # # # # # #
    # show plugin help
    # TODO: need a way to overwrite help for existing commands
    for d in $(find "$BASE_DIR/plugins" -maxdepth 1 -mindepth 1 -type d | sort -t '\0' -n); do
        if [ ! -f "$d/help.sh" ]; then
            break;
        fi

        . "$d/help.sh"
    done

    # # # # # # # # # # # # # # # # # # # #
    # show custom commands help
    if [ -f "$PROJECT_CONFIG" ]; then
        # fetch script keys
        COMMAND_KEYS=$(cat "$PROJECT_CONFIG" | jq -crM '.scripts | keys[]')

        if [ ! -z "$COMMAND_KEYS" ]; then
            printf "CUSTOM COMMANDS:\n"

            while read -r KEY; do
                DESCRIPTION=$(cat "$PROJECT_CONFIG" | jq -crM --arg cmd "$KEY" '.scripts[$cmd]["description"]')

                # string length
                COUNT=${#KEY}
                printf "    ${BLUE}${KEY}${NORMAL}${HELP_SPACE:$COUNT}${DESCRIPTION}\n"
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
    local TYPES=("php laravel nodejs django")

    # check for available parameters
    for i in "$@"; do
        case $i in
        -t=*|--type=*)
            # save type parameter if available
            TYPE="${i#*=}"
            shift
            ;;
        *)
            DIR="$i"
            shift
            ;;
        esac
    done

    # check if type is actually supported
    if [[ ! " ${TYPES[@]} " =~ " ${TYPE} " ]]; then
        printf "${RED}Unsupported project type!${NORMAL}\n"
        exit 1
    fi

    mkdir -p "$DIR"

    cp -r "${BASE_DIR}/environments/${TYPE}/" "$DIR"
    cp "$DIR/.env.example" "$DIR/.env" && touch "$DIR/src/.env"
}


needs_help() {
    if [ "$1" == "-h" ] || [ "$2" == "-h" ]; then
        return 0
    fi

    return 1
}


# # # # # # # # # # # # # # # # # # # #
# synchronize project structure
# project sync
sync_structure() {
    if [ -d "$BASE_DIR/environments/" ] && [ ! -z "$PROJECT_TYPE" ]; then
        cp -ir "${BASE_DIR}/environments/${PROJECT_TYPE}/" "$WDIR"
    else
        printf "${RED}Unsupported project type!${NORMAL}\n"
    fi

    return 0
}


# # # # # # # # # # # # # # # # # # # #
# get unix timestamp from file
unixtime_from_file() {
    if [ "$SYSTEM" == "Darwin" ]; then
        if stat -f %y "$1" &> /dev/null; then
            echo $(stat -f %m "$1")
        elif php -v &> /dev/null; then
            echo $(php -r "echo filemtime('${1}');" 2> /dev/null)
        fi
    else
        echo $(stat -c %Y "$1")
    fi
}


filemtime() {
    [ ! -z "$1" ] && echo $(expr $(date +%s) - $(printf "%.0f" $1)) || echo 0
}


# # # # # # # # # # # # # # # # # # # #
# check if any error occured
has_errors() {
    [ ! -f "$OUTPUT_FILE" ] && [ ! -s "$OUTPUT_FILE" ] return 1

    if grep -qi 'error\|invalid' "$OUTPUT_FILE"; then
        printf "${RED}"
        cat "$OUTPUT_FILE"
        printf "${NORMAL}"
        return 0
    elif grep -qi 'warning' "$OUTPUT_FILE"; then
        printf "${YELLOW}"
        cat "$OUTPUT_FILE"
        printf "${NORMAL}"
        return 0
    fi

    return 1
}


# # # # # # # # # # # # # # # # # # # #
# reset error file
reset_output() {
    echo '' > "$OUTPUT_FILE"
}


# # # # # # # # # # # # # # # # # # # #
# reset asked file
reset_asked() {
    rm "$ASKED_FILE"
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
    if [ ! -d "${BASE_DIR}/completions" ]; then
        mkdir "${BASE_DIR}/completions"
    fi

    echo "#compdef project

    _project() {
        local -a commands
            commands=(
            'config:Read and write local config settings.'
            'init:Setup default project structure in the specified directory.'
            'list:List all projects.'
            'open:Open a project in a new tab.'
            'plugin:Install, uninstall, update and list plugins.'
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
            'php:Run PHP commands.'
            'tinker:Interact with your application.'
            'npm:Run npm commands.'
            'python:Run python commands.'
            'django:Run application specific django commands.'
            'django-admin:Run django-admin commands.'
        )

        if (( CURRENT == 2 )); then
            _describe -t commands 'commands' commands
        fi

        return 0
    }

    _project" > "$BASE_DIR/completions/_project"
}

is_service_running() {
    local SERVICE=$1
    local ID=$(project compose ps -q $1)

    [[ -z "${ID// }" ]] && return 1

    return 0
}

check_ports() {
    local PORTS=${1:-$(cat .env | grep '_PORT=' | sed -e 's/[A-Z_]*_PORT=\(.*\)/\1/')}

    [ -z "$PORTS" ] && return 0

    PORTS=$(echo $PORTS | paste -sd "," - | sed -e 's/ /,/g')

    if lsof -i ":$PORTS" | grep LISTEN > /dev/null; then
        printf "${RED}Unable to start application - ports already in use.${NORMAL}\n"
        exit 1
    fi
}

store_config() {
    if [ ! -z "$1" ]; then
        BASE_CONFIG_JSON=$(echo "$1" | jq -c .)
        echo "$BASE_CONFIG_JSON" | jq -M . > "$BASE_CONFIG"
    fi
}

install_plugin() {
    # exit the script if no plugin specified
    [ -z "$1" ] && printf "${YELLOW}Please specify a plugin!${NORMAL}\n" && exit 1

    local REPO="https://github.com/${1}.git"

    if [ $1 == ^https://* ]; then
        REPO="$1"
    fi

    if ( cd "$BASE_DIR/plugins/." && git clone "$REPO" ); then
        printf "${GREEN}Plugin '${1}' installed!${NORMAL}\n"
    else
        printf "${RED}Plugin '${1}' could not be installed!${NORMAL}\n"
    fi
}

uninstall_plugin() {
    # exit the script if no plugin specified
    [ -z "$1" ] && printf "${YELLOW}Please specify a plugin!${NORMAL}\n" && exit

    local PLUGIN=${1#*/}

    if [ ! -d "$BASE_DIR/plugins/$PLUGIN" ]; then
        printf "${YELLOW}The plugin '${1}' is not installed!${NORMAL}\n"
        exit 1
    fi

    rm -rf "$BASE_DIR/plugins/$PLUGIN"
    printf "${GREEN}Plugin '${1}' uninstalled!${NORMAL}\n"
}

update_plugin() {
    # exit the script if no plugin specified
    [ -z "$1" ] && printf "${YELLOW}Please specify a plugin!${NORMAL}\n" && exit 1

    local PLUGIN=${1#*/}

    if [ ! -d "$BASE_DIR/plugins/$PLUGIN" ]; then
        printf "${YELLOW}The plugin '${1}' is not installed!${NORMAL}\n"
        exit 1
    fi

    if ( cd "$BASE_DIR/plugins/$PLUGIN" && git pull ); then
        printf "${GREEN}Plugin '${1}' successfully updated!${NORMAL}\n"
    else
        printf "${RED}Unable to update plugin '${1}'!${NORMAL}\n"
    fi
}

yaml2json() {
    if ! ruby -v &> /dev/null; then
        printf "${RED}To convert YAML to JSON, ruby needs to be installed.${NORMAL}\n" && exit 1
    fi

    ruby -r yaml -r json -e 'puts YAML.load($stdin.read).to_json'
}
