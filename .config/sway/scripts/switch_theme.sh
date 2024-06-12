#!/bin/sh

set_neovim_theme() {
  for server in $(nvr --nostart --serverlist)
  do
    nvr --nostart --servername "$server" -cc "set background=$1"
  done
}

# switch theme
if grep gruvbox_light ~/.config/sway/config >/dev/null 2>/dev/null; then
  sed -i -e 's|gruvbox_light|gruvbox_dark|g' ~/.config/sway/config
  sed -i -e 's|gruvbox_light|gruvbox_dark|g' ~/.config/kitty/kitty.conf
  sed -i -e 's|gruvbox-light|gruvbox-dark|g' ~/.config/alacritty/alacritty.toml
  sed -i -e 's|theme "gruvbox-light"|theme "gruvbox-dark"|g' ~/.config/zellij/config.kdl
  sed -i -e 's|gruvbox-light|gruvbox-dark|g' ~/.gitconfig
  sed -i -e 's|vim.o.background = "light"|vim.o.background = "dark"|g' ~/.config/nvim/init.vim
  set_neovim_theme dark
else
  sed -i -e 's|gruvbox_dark|gruvbox_light|g' ~/.config/sway/config
  sed -i -e 's|gruvbox_dark|gruvbox_light|g' ~/.config/kitty/kitty.conf
  sed -i -e 's|gruvbox-dark|gruvbox-light|g' ~/.config/alacritty/alacritty.toml
  sed -i -e 's|theme "gruvbox-dark"|theme "gruvbox-light"|g' ~/.config/zellij/config.kdl
  sed -i -e 's|gruvbox-dark|gruvbox-light|g' ~/.gitconfig
  sed -i -e 's|vim.o.background = "dark"|vim.o.background = "light"|g' ~/.config/nvim/init.vim
  set_neovim_theme light
fi

pkill --signal SIGUSR1 kitty
