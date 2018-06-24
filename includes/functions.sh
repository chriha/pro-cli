#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# shows the help
help() {
    printf "${BLUE}pro-cli ${BOLD}v${VERSION}${NORMAL}\n"
    printf "help: project [command]\n\n"
    printf "COMMANDS:\n"
    if [ -f "$PROJECT_CONFIG" ]; then
        printf "    ${BLUE}config${NORMAL}${HELP_SPACE:6}Read and write project configurations.${NORMAL}\n"
        printf "    ${BLUE}hints${NORMAL}${HELP_SPACE:5}Show a random hint.\n"
        printf "    ${BLUE}init${NORMAL}${HELP_SPACE:4}Setup default project structure in the specified directory.\n"
        printf "    ${BLUE}list${NORMAL}${HELP_SPACE:4}List all projects.\n"
        printf "    ${BLUE}open${NORMAL}${HELP_SPACE:4}Open a project in a new tab.\n"
        printf "    ${BLUE}plugins${NORMAL}${HELP_SPACE:7}Install, uninstall, update and list plugins.\n"
        printf "    ${BLUE}self-update${NORMAL}${HELP_SPACE:11}Update pro-cli manually.\n"
        printf "    ${BLUE}sync${NORMAL}${HELP_SPACE:4}Sync directory structure with pro-cli.\n"
    else
        printf "    ${BLUE}config${NORMAL}${HELP_SPACE:6}Read and write project configurations.${NORMAL}\n"
        printf "    ${BLUE}hints${NORMAL}${HELP_SPACE:5}Show a random hint.\n"
        printf "    ${BLUE}init${NORMAL}${HELP_SPACE:4}Setup default project structure in the specified directory.\n"
        printf "    ${BLUE}list${NORMAL}${HELP_SPACE:4}List all projects.\n"
        printf "    ${BLUE}open${NORMAL}${HELP_SPACE:4}Open a project in a new tab.\n"
        printf "    ${BLUE}plugins${NORMAL}${HELP_SPACE:7}Install, uninstall, update and list plugins.\n"
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
# Show how to use the plugins command
# # # # # # # # # # # # # # # # # # # #
help_plugins() {
    if [ -z "$1" ]; then
        printf "${YELLOW}COMMANDS:${NORMAL}\n"
        printf "    ${BLUE}install${NORMAL}${HELP_SPACE:7}Install project's required plugins or specify one.${NORMAL}\n"
        printf "    ${BLUE}uninstall${NORMAL}${HELP_SPACE:9}Uninstall the specified plugin.\n"
        printf "    ${BLUE}update${NORMAL}${HELP_SPACE:6}Update the specified plugin.\n"
        printf "    ${BLUE}show${NORMAL}${HELP_SPACE:4}List all or a specific plugin.\n"
    elif [ "$1" == "show" ]; then
        printf "${YELLOW}USAGE:${NORMAL}\n"
        printf "project plugins show [options] [argument]\n"
        printf "\n${YELLOW}ARGUMENTS:${NORMAL}\n"
        printf "    ${BLUE}plugin${NORMAL}${HELP_SPACE:6}Plugin ID from the official plugins list.${NORMAL}\n"
        printf "\n${YELLOW}OPTIONS:${NORMAL}\n"
        printf "    ${BLUE}-i, --installed${NORMAL}${HELP_SPACE:15}List all installed plugins.${NORMAL}\n"
        printf "    ${BLUE}-a, --available${NORMAL}${HELP_SPACE:15}List all available plugins.${NORMAL}\n"
        printf "    ${BLUE}-h, --help${NORMAL}${HELP_SPACE:10}Show this help.${NORMAL}\n"
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
    if [[ ${TYPES[@]} =~ ${TYPE} ]]; then
        mkdir -p "$DIR"
        cp -r "${BASE_DIR}/environments/${TYPE}/" "$DIR"
        cp "$DIR/.env.example" "$DIR/.env" && touch "$DIR/src/.env"

        return 0
    fi

    for d in $(find "$BASE_DIR/plugins" -mindepth 1 -maxdepth 1 -type d | sort -t '\0' -n); do
        [ ! -f "$d/init.sh" ] && continue

       . "$d/init.sh"
    done

    printf "${RED}unsupported project type!${NORMAL}\n"
    exit 1
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
    rm -f "$ASKED_FILE"
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
            'hints:Show a random hint.'
            'init:Setup default project structure in the specified directory.'
            'list:List all projects.'
            'open:Open a project in a new tab.'
            'plugins:Install, uninstall, update and list plugins.'
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

# # # # # # # # # # # # # # # # # # # #
# Check if ports are already in use
#
# Globals:
#   WDIR
# # # # # # # # # # # # # # # # # # # #
check_ports() {
    local PORTS=${1:-$(cat "$WDIR/.env" | grep '_PORT=' | sed -e 's/[A-Z_]*_PORT=\(.*\)/\1/')}

    [ -z "$PORTS" ] && return 0

    PORTS=$(echo $PORTS | paste -sd "," - | sed -e 's/ /,/g')

    if lsof -i ":$PORTS" | grep LISTEN > /dev/null; then
        err "Unable to start application - ports already in use." && exit 1
    fi
}

# # # # # # # # # # # # # # # # # # # #
# Store new JSON config
#
# Globals:
#   BASE_CONFIG_JSON
# Arguments:
#   CONFIG_JSON
# # # # # # # # # # # # # # # # # # # #
store_config() {
    BASE_CONFIG_JSON=$(echo "$1" | jq -c . 2>/dev/null)

    # needs to be valid JSON
    if [ ! -z "$BASE_CONFIG_JSON" ] && [[ $BASE_CONFIG_JSON == {* ]]; then
        echo "$BASE_CONFIG_JSON" | jq -M . > "$BASE_CONFIG"
    fi
}

# # # # # # # # # # # # # # # # # # # #
# Print error messages
#
# Arguments:
#   ERROR_MESSAGES
# # # # # # # # # # # # # # # # # # # #
err() {
    #printf "[$(date +'%Y-%m-%d %H:%M:%S')]: ${RED}$@${NORMAL}\n" >&2
    printf "${RED}$@${NORMAL}\n" >&2
}

# # # # # # # # # # # # # # # # # # # #
# Print warnings
#
# Arguments:
#   WARNINGS
# # # # # # # # # # # # # # # # # # # #
warn() {
    printf "${YELLOW}$@${NORMAL}\n" >&2
}

# # # # # # # # # # # # # # # # # # # #
# Print success message
#
# Arguments:
#   MESSAGE
# # # # # # # # # # # # # # # # # # # #
succ() {
    printf "${GREEN}$@${NORMAL}\n" >&2
}

# # # # # # # # # # # # # # # # # # # #
# install plugins required in project
#
# Globals:
#   PROJECT_CONFIG_JSON
# # # # # # # # # # # # # # # # # # # #
install_project_plugins() {
    local PROJECT_REQUIREMENTS=$(echo "$PROJECT_CONFIG_JSON" | jq -r '.require | .[]')

    [ -z "$PROJECT_REQUIREMENTS" ] && warn "No dependencies found." && exit

    # loop through each requirement and check if it's installed
    while read -r PLUGIN; do
        local NAME=${PLUGIN#*/}

        if [ -d "$BASE_DIR/plugins/$NAME" ]; then
            read -p "'$NAME' is already installed. Would you like to update? [y|n]: " -n 1 -r
            printf "\n"

            [[ ! $REPLY =~ ^[Yy]$ ]] && continue

            update_plugin $NAME
        else
            install_plugin $PLUGIN
        fi

    done <<< "$PROJECT_REQUIREMENTS"

    exit
}

# # # # # # # # # # # # # # # # # # # #
# Compare two versions
# https://stackoverflow.com/a/4025065
#
# Globals:
#   BASE_DIR
#   GREEN
#   NORMAL
# Arguments:
#   PLUGIN (vendor/name)
# # # # # # # # # # # # # # # # # # # #
install_plugin() {
    [ -z "$1" ] && warn "Please specify a plugin to install!" && exit 1

    local REPO=$(get_repo_url "$1")
    local NAME=${1#*/}

    if [ -d "${BASE_DIR}/plugins/${NAME}" ]; then
        read -p "'${NAME}' is already installed. Would you like to update? [y|n]: " -n 1 -r
        printf "\n"

        [[ ! $REPLY =~ ^[Yy]$ ]] && return 0

        update_plugin $NAME
    elif ( cd "${BASE_DIR}/plugins/." && git clone -q "${REPO}" ); then
        succ "Plugin '${1}' installed!"
    else
        err "Plugin '${1}' could not be installed!"
    fi
}

# # # # # # # # # # # # # # # # # # # #
# uninstall the specified plugin
#
# Arguments:
#   PLUGIN_NAME
# # # # # # # # # # # # # # # # # # # #
uninstall_plugin() {
    [ -z "$1" ] && warn "Please specify a plugin!" && exit

    local PLUGIN=${1#*/}

    if [ ! -d "${BASE_DIR}/plugins/${PLUGIN}" ]; then
        warn "The plugin '${1}' is not installed!" && exit 1
    fi

    rm -rf "${BASE_DIR}/plugins/${PLUGIN}"
    succ "Plugin '${1}' uninstalled!"
}

# # # # # # # # # # # # # # # # # # # #
# updates the specified plugin
#
# Globals:
#   BASE_DIR
#   GREEN
# Arguments:
#   PLUGIN_NAME / REPO_URL
#   VERSION / BRANCH
# # # # # # # # # # # # # # # # # # # #
update_plugin() {
    # exit the script if no plugin specified
    [ -z "$1" ] && warn "Please specify a plugin!" && exit 1

    local PLUGIN=${1#*/}

    if [ ! -d "$BASE_DIR/plugins/$PLUGIN" ]; then
        warn "The plugin '${1}' is not installed!" && exit 1
    fi

    printf "Updating plugin '$PLUGIN' ... "

    if cd "$BASE_DIR/plugins/$PLUGIN" && git pull -q; then
        succ "done" && return 0
    fi

    err "\nUnable to update plugin '${1}'!" && exit 1
}

# # # # # # # # # # # # # # # # # # # #
# convert yaml to json
# # # # # # # # # # # # # # # # # # # #
yaml2json() {
    if ! ruby -v &> /dev/null; then exit 1; fi

    ruby -r yaml -r json -e 'puts YAML.load($stdin.read).to_json'
}

# # # # # # # # # # # # # # # # # # # #
# Get the URL of a repository
#
# Todo:
#   - fetch URL to repo from plugins list
#
# Arguments:
#   PLUGIN_NAME
# # # # # # # # # # # # # # # # # # # #
get_repo_url() {
    if [[ $1 =~ ^https://* ]]; then
        echo "$1"
    elif [[ "$1" == */* ]]; then
        echo "https://github.com/${1}.git"
    else
        echo "https://github.com/pro-cli/${1}.git"
    fi
}


# # # # # # # # # # # # # # # # # # # #
# Show random hint
# # # # # # # # # # # # # # # # # # # #
random_hint() {
    local JSON=$(cat "$HINTS_FILE")
    local LENGTH=$(echo $JSON | jq '. | keys | length')
    local INDEX=$(($RANDOM % $LENGTH))
    local KEY=$(printf "$JSON" | jq -r ". | keys | .[$INDEX]")

    local HINT_DESC=$(echo "$JSON" | jq -r --arg string "$KEY" '.[$string].description')
    local HINT_CMD=$(echo "$JSON" | jq -r --arg string "$KEY" '.[$string].command')

    printf "${BLUE}${HINT_DESC}${NORMAL}\n"
    [ ! -z "$HINT_CMD" ] && printf "    ${HINT_CMD}\n"
}


# # # # # # # # # # # # # # # # # # # #
# Check if a random hint can be shown
# # # # # # # # # # # # # # # # # # # #
can_show_hint() {
    local CHECK=$(echo "$BASE_CONFIG_JSON" | jq -r '.hints.enabled | select(.==false)')

    [ ! -z "$CHECK" ] && return 1

    local SHOWN=$(echo "$BASE_CONFIG_JSON" | jq -r '.hints.shown_at | select(.!=null)')
    local TIME=$(date +%Y%m%d%H)

    [ ! -z "$SHOWN" ] && [ "$SHOWN" = "$TIME" ] && return 1

    local JSON=$(echo $BASE_CONFIG_JSON | jq ".hints.shown_at = \"${TIME}\"" | jq -M .)
    store_config "$JSON"

    return 0
}

# # # # # # # # # # # # # # # # # # # #
# Check if the web instance is running
# # # # # # # # # # # # # # # # # # # #
is_web_running() {
    if ! project status | grep 'web_1.*Up' >/dev/null; then
        return 1
    fi

    return 0
}

