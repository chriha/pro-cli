#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# execute python commands
if [ "$1" == "python" ]; then
    shift
    $RUN web python $@
    exit

# # # # # # # # # # # # # # # # # # # #
# execute django-admin commands
elif [ "$1" == "django-admin" ]; then
    shift
    $RUN web django-admin $@
    exit

# # # # # # # # # # # # # # # # # # # #
# execute django commands
elif [ "$1" == "django" ]; then
    shift
    $RUN web python manage.py $@
    exit

fi
