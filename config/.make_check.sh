#!/bin/bash

if [ "$(pwd)" = "/home/jingle/data/jhgame/server_git" ]; then
	echo "in server path, plz use tl make"
	exit 1
else
    make $@
fi

