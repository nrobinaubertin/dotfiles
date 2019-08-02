#!/bin/sh

# set keyboard map
setxkbmap fr

# start ssh-agent
eval $(ssh-agent)

# PATH
. "${HOME}/.config/pathrc"

# statusbar for dwm
while true; do
    xsetroot -name "$(get status ' | ' 2>/dev/null)"
    sleep 1m
done &

# autostart st
st &

exec dwm
