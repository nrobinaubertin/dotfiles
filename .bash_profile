if [ -z "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ "$XDG_VTNR" -eq 1 ] && [ "$TERM" = "linux" ]
then
  if command -v sway >/dev/null; then
    exec sway
  else
    if command -v startx >/dev/null; then
      exec startx
    fi
  fi
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
