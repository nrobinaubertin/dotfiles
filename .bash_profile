if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ "$TERM" = "linux" ]
then
    exec startx
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
