#!/bin/sh

set_neovim_bg() {
  for server in $(nvr --nostart --serverlist)
  do
    nvr --nostart --servername "$server" -cc "set background=$1"
  done
}

# switch theme
if grep gruvbox_light ~/.config/sway/config >/dev/null 2>/dev/null; then
  sed -i -e 's|gruvbox_light|gruvbox_dark|g' ~/.config/sway/config
  sed -i -e 's|gruvbox_light|gruvbox_dark|g' ~/.config/kitty/kitty.conf
  sed -i -e 's|vim.o.background = "light"|vim.o.background = "dark"|g' ~/.config/nvim/init.vim
  set_neovim_bg dark
else
  sed -i -e 's|gruvbox_dark|gruvbox_light|g' ~/.config/sway/config
  sed -i -e 's|gruvbox_dark|gruvbox_light|g' ~/.config/kitty/kitty.conf
  sed -i -e 's|vim.o.background = "dark"|vim.o.background = "light"|g' ~/.config/nvim/init.vim
  set_neovim_bg light
fi

pkill --signal SIGUSR1 kitty
