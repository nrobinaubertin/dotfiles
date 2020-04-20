if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ "$TERM" = "linux" ]
then

  # start ssh-agent
  eval $(ssh-agent)

  # PATH
  . "${HOME}/.config/pathrc"

  if command -v sway >/dev/null; then
    exec sway
  fi
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
