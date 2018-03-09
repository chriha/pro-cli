#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# run jenkins builds
if [ "$1" == "build" ]; then
    shift

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

    JENKINS_PARAMS=${JENKINS_PARAMS:1}

    echo "$JENKINS_USER:$JENKINS_TOKEN"
    echo "$JENKINS_PARAMS"
    echo "$JENKINS_URL/job/$JENKINS_PATH/$JENKINS_BUILD_TYPE"

    CRUMB=$(curl -u "$JENKINS_USER:$JENKINS_TOKEN" \
        -s "$JENKINS_URL/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")

    if [ -z "$JENKINS_PARAMS" ]; then
        curl -u "$JENKINS_USER:$JENKINS_TOKEN" \
            -X POST "$JENKINS_URL/job/$JENKINS_PATH/$JENKINS_BUILD_TYPE" \
            -H "$CRUMB"
    else
        JENKINS_BUILD_TYPE="buildWithParameters"

        curl --data "$JENKINS_PARAMS" \
            -u "$JENKINS_USER:$JENKINS_TOKEN" \
            -X POST "$JENKINS_URL/job/$JENKINS_PATH/$JENKINS_BUILD_TYPE" \
            -H "$CRUMB"
    fi

    curl -u "$JENKINS_USER:$JENKINS_TOKEN" \
        -X POST "$JENKINS_URL/job/$JENKINS_PATH/polling" \
        -H "$CRUMB"

    exit

fi
