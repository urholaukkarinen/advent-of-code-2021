#!/bin/bash

trunk="https://github.com/urholaukkarinen/hello-world-devcontainers/trunk"

lang="$1"
day="$2"

if [ "$lang" == "list" ]; then
    svn ls $trunk | grep "/" | cut -d '/' -f 1
elif [ ! -d "./$day" ]; then
    svn export $trunk/$lang $day
else
    echo "$day already exists."
    exit 1
fi
