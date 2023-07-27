if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ "$TERM" = "linux" ]
then

  # PATH
  . "${HOME}/.config/pathrc"

  if command -v sway >/dev/null; then
    export XDG_CURRENT_DESKTOP=sway
    exec sway
  fi
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
