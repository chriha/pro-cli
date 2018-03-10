#!/usr/bin/env bash

is_build_available() {
    local RESP_HEADERS=$(curl -sSL -u "$1" -D - -X POST "$2/$3/api/json" -H "Jenkins-Crumb: $4")

    if echo $RESP_HEADERS | grep '404 Not Found'; then
        echo "false"
    else
        echo "true"
    fi

    return 0
}

get_crumb() {
    echo $(curl -u $1 -s "$2/crumbIssuer/api/json" | jq -r '.crumb')
    return 0
}


# # # # # # # # # # # # # # # # # # # #
# run jenkins builds
if [ "$1" == "build" ]; then
    shift

    JENKINS_OUTPUT=false

    if [ "$1" == "-o" ] || [ "$1" == "--output" ]; then
        shift
        JENKINS_OUTPUT=true
    fi

    JENKINS_URL=$(cat $PC_BASE_CONF | jq -r '.jenkins.url')
    JENKINS_USER=$(cat $PC_BASE_CONF | jq -r '.jenkins.user')
    JENKINS_TOKEN=$(cat $PC_BASE_CONF | jq -r '.jenkins.token')

    if [ "$JENKINS_URL" == "null" ] || [ -z "$JENKINS_URL" ]; then
        printf "${YELLOW}No Jenkins URL set. You can set it via:${NORMAL}\nproject config -g jenkins.url YOUR_URL\n"
        exit
    elif [ "$JENKINS_USER" == "null" ] || [ -z "$JENKINS_USER" ]; then
        printf "${YELLOW}No Jenkins user set. You can set it via:${NORMAL}\nproject config -g jenkins.user YOUR_USER\n"
    elif [ "$JENKINS_TOKEN" == "null" ] || [ -z "$JENKINS_TOKEN" ]; then
        printf "${YELLOW}No Jenkins token set. You can set it via:${NORMAL}\nproject config -g jenkins.user YOUR_TOKEN\n"
    fi

    AUTH="$JENKINS_USER:$JENKINS_TOKEN"

    if [ -z "$1" ]; then
        printf "${YELLOW}No Jenkins build specified. Set it in your project's ${BLUE}pro-cli.json${NORMAL}\n"
        exit
    fi

    JENKINS_BUILD=$1
    JENKINS_PATH=$(cat $PC_CONF | jq -r --arg BUILD "$JENKINS_BUILD" '.builds[$BUILD].path')

    if [ "$JENKINS_PATH" == "null" ] || [ -z "$JENKINS_PATH" ]; then
        printf "${YELLOW}No path to this build specified. Set it in your project's ${BLUE}pro-cli.json${NORMAL}\n"
        exit
    fi

    JENKINS_JOB_URL="$JENKINS_URL/job/$JENKINS_PATH"

    shift
    JENKINS_BUILD_TYPE="build"
    JENKINS_PARAMS=""

    # get parameters for the build which are specified in pro-cli.json
    ALL_PARAMS=$(cat $PC_CONF | jq --arg BUILD "$JENKINS_BUILD" '.builds[$BUILD].params')

    # overwrite parameters specified in the command with the parameters in pro-cli.json
    for var in "$@"; do
        param=${var#"--"}
        key=$(echo $param | sed -n 's/\([a-z\-_]*\)=.*/\1/p')
        value=$(echo $param | sed -n 's/[a-z\-_]*=\([a-z\-_]*\)/\1/p')

        ALL_PARAMS=$(echo $ALL_PARAMS | jq ".$key = \"${value}\"" | jq -M .)
    done

    if [ "$ALL_PARAMS" != "null" ] && [ ! -z "$ALL_PARAMS" ]; then
        # format the parameters from JSON to cURL valid parameters
        JENKINS_PARAMS=$(echo $ALL_PARAMS | jq -crM 'to_entries | map([.key, .value]) | map(join("=")) | join("&")')
    fi

    CRUMB=$(get_crumb $AUTH $JENKINS_URL)

    NEXT_BUILD=$(curl -u $AUTH -H "Jenkins-Crumb: $CRUMB" -X POST "$JENKINS_JOB_URL/api/json?tree=nextBuildNumber" -s)

    if !(echo $NEXT_BUILD | jq -e . >/dev/null 2>&1); then
        printf "${RED}Unable to fetch next build number for build status polling.${NORMAL}\n"
        exit
    fi

    NEXT_BUILD=$(echo $NEXT_BUILD | jq -r '.nextBuildNumber')

    if [ -z "$JENKINS_PARAMS" ]; then
        curl -u $AUTH -H "Jenkins-Crumb: $CRUMB" -X POST "$JENKINS_JOB_URL/$JENKINS_BUILD_TYPE"
    else
        JENKINS_BUILD_TYPE="buildWithParameters"

        curl --data "$JENKINS_PARAMS" -u $AUTH -H "Jenkins-Crumb: $CRUMB" \
            -X POST "$JENKINS_JOB_URL/$JENKINS_BUILD_TYPE"
    fi

    printf "${GREEN}Build started.${NORMAL}\n"

    if ! $JENKINS_OUTPUT; then
        exit;
    fi

    printf "${YELLOW}########################################\n"
    printf "# BUILD CONSOLE OUTPUT:\n"
    printf "########################################${NORMAL}\n"
    printf "Waiting for build status ..."

    AVAILABLE=$(is_build_available $AUTH $JENKINS_JOB_URL $NEXT_BUILD $CRUMB)

    while [ "$AVAILABLE" != "true" ]; do
        sleep 1
        AVAILABLE=$(is_build_available $AUTH $JENKINS_JOB_URL $NEXT_BUILD $CRUMB)
    done

    IN_PROGRESS=true
    START="0"

    printf "${CLEAR_LINE}"

    HEADERS_FILE="$WDIR/temp/_jenkins-headers.txt"

    if [ ! -d "$WDIR/temp" ]; then
        mkdir -p "$WDIR/temp"
    fi

    while [ "$IN_PROGRESS" == true ]; do
        RESPONSE=$(curl -is -u $AUTH -H "Jenkins-Crumb: $CRUMB" -D "$HEADERS_FILE" \
            -X POST "$JENKINS_JOB_URL/$NEXT_BUILD/logText/progressiveText?start=$START")

        IS_HEADER=true
        IN_PROGRESS=false

        while read -r line; do
            if $IS_HEADER && [[ $line = $'\r' ]]; then
                IS_HEADER=false
            elif $IS_HEADER && ( echo "$line" | grep -q 'X-More-Data:' ); then
                IN_PROGRESS=true
            elif $IS_HEADER && ( echo "$line" | grep -q 'X-Text-Size:' ); then
                START=$(cat "$HEADERS_FILE" | sed -n 's/X-Text-Size: \(.*\)$/\1/p')
                START=${START%$'\r'}
            elif ! $IS_HEADER; then
                echo "$line"
            fi
        done <<< "$RESPONSE"

        if $IN_PROGRESS; then
            sleep 2
        fi
    done

    exit

fi
