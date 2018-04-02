#!/usr/bin/env bash

BASE_DIR="$HOME/.pro-cli"

. "$BASE_DIR/includes/bootstrap.sh"

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
fi

# # # # # # # # # # # # # # # # # # # #
# show help immediately
if [ $# -eq 0 ] || [ "$1" == "help" ]; then
    help && exit
fi


# # # # # # # # # # # # # # # # # # # #
# project plugin [install|uninstall|update|list] [VENDOR/PLUGIN_NAME]
if [ "$1" == "plugin" ]; then
    shift

    if [ "$1" == "install" ]; then
        [ ! -z "$2" ] && shift && install_plugin $@ && exit

        install_project_plugins && exit
    elif [ "$1" == "uninstall" ] && [ ! -z "$2" ]; then
        shift && uninstall_plugin $@
        exit
    elif [ "$1" == "update" ]; then
        shift
        update_plugin $@
        exit
    elif [ "$1" == "list" ]; then
        for i in $(find "$BASE_DIR/plugins" -mindepth 1 -maxdepth 1 -type d | sort -t '\0' -n); do
            echo "- ${i##*/}"
        done
        exit
    fi

    printf "${YELLOW}Usage:${NORMAL} project plugin [install|uninstall|list] [VENDOR/PLUGIN_NAME]\n"
    exit 1
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
