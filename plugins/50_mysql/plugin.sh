#!/usr/bin/env bash

[ "$1" != "query-logs" ] || [ ! -f "$PROJECT_CONFIG" ] && return
shift

if [ -z "$1" ]; then
    printf "COMMANDS:\n"
    printf "    ${BLUE}clear${NORMAL}${HELP_SPACE:5}Clear the query log.${NORMAL}\n"
    printf "    ${BLUE}disable${NORMAL}${HELP_SPACE:7}Disable query logs.${NORMAL}\n"
    printf "    ${BLUE}enable${NORMAL}${HELP_SPACE:6}Enable query logs.${NORMAL}\n"
    printf "    ${BLUE}tail${NORMAL}${HELP_SPACE:4}Tail query logs.${NORMAL}\n"
    exit

elif [ "$1" == "enable" ]; then
    printf "${YELLOW}Updating config ...${NORMAL} "

    if ! project exec db grep '^general_log_file' /etc/mysql/mysql.conf.d/mysqld.cnf >/dev/null; then
        $COMPOSE exec db bash -c "echo 'general_log_file = /var/lib/mysql/query.log' >> /etc/mysql/mysql.conf.d/mysqld.cnf"
    fi

    if ! $COMPOSE exec db grep '^general_log = ' /etc/mysql/mysql.conf.d/mysqld.cnf >/dev/null; then
        $COMPOSE exec db bash -c "echo 'general_log = 1' >> /etc/mysql/mysql.conf.d/mysqld.cnf"

        printf "${GREEN}done${NORMAL}\n"
        project stop db

        ( $COMPOSE start db ) &> $OUTPUT_FILE &
        spinner $! "${YELLOW}Starting containers ... ${NORMAL}"
        has_errors || printf "${YELLOW}Starting containers ... ${NORMAL}${GREEN}done${NORMAL}\n"

        printf "${YELLOW}Waiting for MySQL to come up ...${NORMAL} "

        while ! $COMPOSE exec -T db sh -c 'mysql -u"$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;"' &>/dev/null; do
            sleep 1
        done

        printf "${GREEN}up${NORMAL}\n"
    else
        $COMPOSE exec -T db sh -c 'mysql -u"$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" -e "SET global general_log = 1;"' &>/dev/null
        printf "${GREEN}done${NORMAL}\n"
    fi

    printf "You can now run 'project query-logs tail -f' to see executed queries.\n"
    exit

elif [ "$1" == "disable" ]; then
    printf "${YELLOW}Disabling query logs ...${NORMAL} "
    $COMPOSE exec -T db sh -c 'mysql -u"$MYSQL_USER" -p"$MYSQL_ROOT_PASSWORD" -e "SET global general_log = 0;"' &>/dev/null
    printf "${GREEN}done${NORMAL}\n"
    exit

elif [ "$1" == "tail" ]; then
    shift && tail $@ "$WDIR/temp/mysql/query.log"
    exit

elif [ "$1" == "clear" ]; then
    echo '' > "$WDIR/temp/mysql/query.log"
    exit

fi
