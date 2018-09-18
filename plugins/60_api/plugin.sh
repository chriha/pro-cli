#!/usr/bin/env bash

[ "$1" != "api" ] && return 0

shift

API_DOC_IMAGE="procli/aglio"
API_DOC_PORT=$(grep API_DOC_PORT "${WDIR}/.env" | sed -e 's/API_DOC_PORT=\(.*\)/\1/')
API_DOC_PORT=${API_DOC_PORT:=8088}
API_MOCK_PORT=$(grep API_MOCK_PORT "${WDIR}/.env" | sed -e 's/API_MOCK_PORT=\(.*\)/\1/')
API_MOCK_PORT=${API_MOCK_PORT:=8087}
API_DOC_DIR="${WDIR}/doc/api"
API_TEMP_DIR="${WDIR}/temp/api"

if [ ! -f "${WDIR}/doc/api/index.apib" ]; then
    err "${RED}API blueprint ${BOLD}./doc/api/index.apib${NORMAL}${RED} does not exist.${NORMAL}" && exit 1
fi

if [ "$1" == "doc" ]; then
    docker run -it --rm -p $API_DOC_PORT:8088 -v "${API_DOC_DIR}":/doc $API_DOC_IMAGE aglio --theme-template triple --theme-variables flatly --host 0.0.0.0 -p 8088 -i /doc/index.apib -s
    exit
elif [ "$1" == "render" ]; then
    docker run -it --rm -v $API_DOC_DIR:/doc -v $API_TEMP_DIR:/tmp $API_DOC_IMAGE aglio --theme-template triple --theme-variables flatly -i /doc/index.apib -o /tmp/api.html
    exit
elif [ "$1" == "lint" ]; then
    docker run -it --rm -v $API_DOC_DIR:/doc -v $API_TEMP_DIR:/tmp $API_DOC_IMAGE aglio --theme-template triple --theme-variables flatly -o /dev/null -i /doc/index.apib
    exit
elif [ "$1" == "aglio" ]; then
    shift
    docker run -it --rm -p $API_DOC_PORT:3000 -v "${API_DOC_DIR}":/doc -v $API_TEMP_DIR:/tmp $API_DOC_IMAGE aglio $@
    exit
fi
