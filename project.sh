#!/usr/bin/env bash

BASE_DIR="$HOME/.pro-cli"

. "$BASE_DIR/includes/bootstrap.sh"

if tmate_status && [ "$1" != "support" ]; then
    printf "${YELLOW}You have active tmate sessions!${NORMAL}\n"
    sleep 1
fi

# # # # # # # # # # # # # # # # # # # #
# show new version info if available
if [ "$VERSION" != "$VERSION_NEW" ] && [ ! -f $ASKED_FILE ]; then
    touch $ASKED_FILE
    printf "${YELLOW}New version available: ${BOLD}${VERSION_NEW}${NORMAL}\n"
    read -p "Would you like to update pro-cli now? [y|n]: " -n 1 -r

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        . "$BASE_DIR/includes/update.sh"
        exit
    fi

    echo
fi

if can_show_hint && [ "$1" != "hints" ]; then
    echo "${YELLOW}Hourly hint --------------------------------------${NORMAL}"
    random_hint
    echo "${YELLOW}--------------------------------------------------${NORMAL}"
    sleep 5
fi

# # # # # # # # # # # # # # # # # # # #
# show help immediately
if [ $# -eq 0 ] || [ "$1" == "help" ]; then
    help && exit
fi


# # # # # # # # # # # # # # # # # # # #
# project plugins [install|uninstall|update|list] [VENDOR/PLUGIN_NAME]
if [ "$1" == "plugins" ]; then
    shift

    [ -z "$1" ] && help_plugins && exit 0

    if [ "$1" == "install" ]; then
        [ ! -z "$2" ] && shift && install_plugin $@ && exit

        install_project_plugins && exit
    elif [ "$1" == "uninstall" ] && [ ! -z "$2" ]; then
        shift && uninstall_plugin $@ && exit
    elif [ "$1" == "update" ]; then
        shift && update_plugin $@ && exit
    elif [ "$1" == "search" ]; then
        [ -z "$2" ] && err "Please specify a search parameter." && exit
        shift

        LIST=$(curl -H 'Cache-Control: no-cache' -s "$PLUGINS_LIST_URL")
        echo "$LIST" | jq -r --arg S "$1" '.[] | select((.id | match($S; "i")) or (.title | match($S; "i")) or (.description | match($S; "i"))) | .title + " - " + .description' | sort -t '\0' -n
        exit
    elif [ "$1" == "show" ]; then
        shift

        [ -z "$1" ] && help_plugins "show" && exit 0

        case $1 in
        -i|--installed)
            for i in $(find "$BASE_DIR/plugins" -mindepth 1 -maxdepth 1 -type d | sort -t '\0' -n); do
                echo "${i##*/}"
            done
            ;;
        -h|--help) help_plugins "show" ;;
        -a|--available)
            LIST=$(curl -H 'Cache-Control: no-cache' -s "$PLUGINS_LIST_URL")
            echo "$LIST" | jq -r '. | .[] | .title + " - " + .description' | sort -t '\0' -n
            exit
            ;;
        *)
            LIST=$(curl -H 'Cache-Control: no-cache' -s "$PLUGINS_LIST_URL")
            echo "$LIST" | jq ". | .[] | select( .id == \"$1\")"
            ;;
        esac

        exit
    fi

fi


# # # # # # # # # # # # # # # # # # # #
# include plugins now to allow overwriting commands
for d in $(find "$BASE_DIR/plugins" -maxdepth 1 -mindepth 1 -type d | sort -t '\0' -n) ; do
    [ ! -f "$d/plugin.sh" ] && continue

   . "$d/plugin.sh"
done

# # # # # # # # # # # # # # # # # # # #
# project init [directory] [--type=TYPE]
if [ "$1" == "init" ]; then
    shift
    ( sleep 1 && init_project $@ ) &
    spinner $! "Initializing project files ... "
    printf "${GREEN}done!${NORMAL}\n" && exit

# # # # # # # # # # # # # # # # # # # #
# clone project and run install command if available
elif [ "$1" == "clone" ]; then
    shift

    [ -f "$PROJECT_CONFIG" ] && printf "${RED}You can't clone into another project.${NORMAL}\n" && exit

    CLONE_DIR=$([ ! -z "$2" ] && echo "$2" || basename -s .git "$1")
    printf "${YELLOW}Cloning project into '${CLONE_DIR}' ... ${NORMAL}"

    ! git clone -q $@ && exit

    printf "${GREEN}done${NORMAL}\n"

    [ ! -f "${CLONE_DIR}/pro-cli.json" ] && exit

    cd "$CLONE_DIR"
    CLONE_INSTALL=$(cat pro-cli.json | jq -r '.scripts.install | select(.!=null)')

    [ -z "$(cat pro-cli.json | jq -r '.scripts.install | select(.!=null)')" ] && exit

    read -p "${YELLOW}Would you like to install the project?${NORMAL} [y|n]: " -n 1 -r
    printf "\n"

    [[ ! $REPLY =~ ^[Yy]$ ]] && exit

    project install
    exit

# # # # # # # # # # # # # # # # # # # #
# sync directory structure with pro-cli
elif [ "$1" == "sync" ]; then
    sync_structure
    exit

# # # # # # # # # # # # # # # # # # # #
# get and set config settings
elif [ "$1" == "config" ]; then
    shift

    if [ "$1" == "-g" ] || [ "$1" == "--global" ]; then
        shift
        FILE_PATH="$BASE_CONFIG"
    else
        FILE_PATH="$PROJECT_CONFIG"
    fi

    # just print the config
    if [ $# -eq 0 ] && [ -f "$FILE_PATH" ]; then
        cat "$FILE_PATH" | jq .
        exit
    fi

    SELECTION=".${1}"

    if [ ! -z "$2" ]; then
        #PC_VALUE=$(echo "${2}" | sed -e 's/"/\\"/g' -e 's/^\\"/"/1' -e 's/\\"$/"/')

        if $(echo $2 | jq . > /dev/null 2>&1); then
            JSON=$(cat $FILE_PATH | jq "$SELECTION = ${2}" | jq -M .)
        else
            JSON=$(cat $FILE_PATH | jq "$SELECTION = \"${2}\"" | jq -M .)
        fi

        # prevent braking the config file
        [ -z "$JSON" ] && printf "${RED}Invalid value!${NORMAL}\n" && exit 1

        printf '%s' "$JSON" > $FILE_PATH
    else
        cat $FILE_PATH | jq "$SELECTION"
    fi

    exit

# # # # # # # # # # # # # # # # # # # #
# project self-update
elif [ "$1" == "self-update" ]; then
    . "$BASE_DIR/includes/update.sh"
    exit

# # # # # # # # # # # # # # # # # # # #
# project self-update
elif [ "$1" == "hints" ]; then
    random_hint
    exit

# # # # # # # # # # # # # # # # # # # #
# project list
elif [ "$1" == "list" ]; then
    echo "$BASE_CONFIG_JSON" | jq '.projects'
    exit

# # # # # # # # # # # # # # # # # # # #
# project open PROJECT_NAME
elif [ "$1" == "open" ]; then
    OPEN=$(echo "$BASE_CONFIG_JSON" | jq -r --arg VAL "$2" '.projects[$VAL]')

    if [ -z "$OPEN" ]; then
        printf "${YELLOW}Project not found ¯\_(ツ)_/¯${NORMAL}\n"
    else
        open_project "$OPEN" "$2"
    fi

    exit

# # # # # # # # # # # # # # # # # # # #
# project api
elif [ "$1" == "api" ]; then
    shift

    # show help
    if [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ -z "$1" ]; then
        printf "${BLUE}project api [command]\n"
        printf "${NORMAL}Your ${BOLD}index.apib${NORMAL} needs to be in ${BOLD}./doc/api/.${NORMAL}${BLUE}\n\n"
        printf "COMMANDS:\n"
        printf "    ${BLUE}doc${NORMAL}${HELP_SPACE:3}Render and serve API documentation.\n"
        printf "    ${BLUE}lint${NORMAL}${HELP_SPACE:4}Validate your API blueprint.\n"
        printf "    ${BLUE}render${NORMAL}${HELP_SPACE:6}Render API blueprint.\n"
        printf "    ${BLUE}serve${NORMAL}${HELP_SPACE:5}Run mock server based on API blueprint.\n"
        printf "    ${BLUE}snowboard${NORMAL}${HELP_SPACE:9}Run Snowboard commands directly.\n"
        printf "\n${NORMAL}Using the API blueprint toolkit ${BOLD}https://github.com/bukalapak/snowboard${NORMAL}.\n"
        exit
    fi

    API_DOC_IMAGE="bukalapak/snowboard"
    API_DOC_PORT=$(grep API_DOC_PORT "${WDIR}/.env" | sed -e 's/API_DOC_PORT=\(.*\)/\1/')
    API_DOC_PORT=${API_DOC_PORT:=8088}
    API_MOCK_PORT=$(grep API_MOCK_PORT "${WDIR}/.env" | sed -e 's/API_MOCK_PORT=\(.*\)/\1/')
    API_MOCK_PORT=${API_MOCK_PORT:=8087}
    API_DOC_DIR="${WDIR}/doc/api"
    API_TEMP_DIR="${WDIR}/temp/api"

    if [ ! -f "${WDIR}/doc/api/index.apib" ]; then
        err "${RED}API blueprint ${BOLD}./doc/api/index.apib${NORMAL}${RED} does not exist.${NORMAL}" && exit 1
    fi

    if [ "$1" == "serve" ]; then
        printf "${YELLOW}Server available at ${BOLD}http://localhost:${API_MOCK_PORT}${NORMAL}\n"
        docker run -it --rm -p $API_MOCK_PORT:8087 -v $API_DOC_DIR:/doc -v $API_TEMP_DIR:/tmp $API_DOC_IMAGE mock -b 0.0.0.0:8087 index.apib
    elif [ "$1" == "doc" ]; then
        printf "${YELLOW}Server available at ${BOLD}http://localhost:${API_DOC_PORT}${NORMAL}\n"
        docker run -it --rm -p $API_DOC_PORT:8088 -v $API_DOC_DIR:/doc -v $API_TEMP_DIR:/tmp $API_DOC_IMAGE --watch html -o /tmp/output.html -b 0.0.0.0:8088 -s index.apib
    elif [ "$1" == "render" ]; then
        docker run -it --rm -v $API_DOC_DIR:/doc -v $API_TEMP_DIR:/tmp $API_DOC_IMAGE html -o /tmp/output.html index.apib
    elif [ "$1" == "lint" ]; then
        docker run -it --rm -v $API_DOC_DIR:/doc -v $API_TEMP_DIR:/tmp $API_DOC_IMAGE html -o /tmp/output.html index.apib
    elif [ "$1" == "snowboard" ]; then
        shift && docker run -it --rm -v $API_DOC_DIR:/doc -p $API_MOCK_PORT:8087 -p $API_DOC_PORT:8088 $API_DOC_IMAGE $@
    fi

    exit

# # # # # # # # # # # # # # # # # # # #
# project support
elif [ "$1" == "support" ]; then
    shift
    # check for requirements
    if ( ! which tmate > /dev/null 2>&1 ); then
        printf "${RED}tmate is not installed!${NORMAL} "

        ( ! $IS_MAC || ! which brew > /dev/null 2>&1 ) && echo "You can find further information at https://tmate.io/" && exit

        echo && read -p "Shall I install tmate for you? [y|n]: " -n 1 -r

        [[ $REPLY =~ ^[Yy]$ ]] && brew install tmate

        exit
    fi

    # show help
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        printf "${BLUE}project support [command]\n\n"
        printf "COMMANDS:\n"
        printf "    ${BLUE}attach${NORMAL}${HELP_SPACE:6}Attach to a new or an existing session.\n"
        printf "    ${BLUE}close${NORMAL}${HELP_SPACE:5}Close all existing (tmux) clients and sessions.\n"
        printf "    ${BLUE}status${NORMAL}${HELP_SPACE:6}Show details of an existing session.\n"
        printf "    ${BLUE}tmate${NORMAL}${HELP_SPACE:5}Run commands on the tmate socket.\n"
        exit
    fi

    if [ -z "$1" ]; then
        if tmate_status; then
            tmate_details
            exit
        fi

        tmate_start
        printf "${BLUE}Here are your connection strings to share:${NORMAL} --------\n"
        tmate_details
    elif [ "$1" == "attach" ]; then
        if ! tmate_status; then
            tmate_start
            read -p "Press [ENTER] to attach to the session"
        fi

        tmate -S /tmp/tmate.sock attach
    elif [ "$1" == "close" ]; then
        ( tmate -S /tmp/tmate.sock kill-session -t 0 && sleep 1 ) &
        spinner $! "Closing tmate session ... "
        printf "Closing tmate session ... ${GREEN}done!${NORMAL}\n"
    elif [ "$1" == "status" ]; then
        if tmate_status; then
            tmate_details && exit 0
        fi

        printf "${YELLOW}No active session.${NORMAL}\n"
    elif [ "$1" == "tmate" ]; then
        tmate -S /tmp/tmate.sock $@
    fi

    exit
fi

# # # # # # # # # # # # # # # # # # # #
# commands that are specified in the local config file
if [ ! -z "$1" ] && [ ! -z "$PROJECT_CONFIG_JSON" ] && [[ $(echo "$PROJECT_CONFIG_JSON" | jq -crM --arg cmd "$1" '.scripts[$cmd]') != "null" ]]; then
    COMMAND=$(echo "$PROJECT_CONFIG_JSON" | jq -crM --arg cmd "$1" 'if (.scripts[$cmd].command | type == "string") then .scripts[$cmd].command else .scripts[$cmd].command | .[] end')

    # concat multiple commands
    if [[ $COMMAND == *$'\n'* ]]; then
        COMMAND=$(echo "$COMMAND" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/ \&\& /g')
    fi

    if [ ! -z "$COMMAND" ] && [ "$COMMAND" != "null" ]; then
        eval $COMMAND
        exit
    fi
fi

printf "${YELLOW}Command not found ¯\_(ツ)_/¯${NORMAL}\n"

