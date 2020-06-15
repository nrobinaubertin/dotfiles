#!/bin/sh

# do not continue if we are not in a bash 4+ shell
# do not continue if we are not running interactively
# do not continue if $HOME is not defined
([ "${BASH_VERSINFO}" -lt 4 ] || [ -z "$PS1" ] || [ -z "$HOME" ]) && return

# Automatically trim long paths in the prompt (requires Bash 4.x)
export PROMPT_DIRTRIM=2

# (bash 4+) enable recursive glob for grep, rsync, ls, ...
shopt -s globstar 2> /dev/null

# Force Bash's Emacs Mode
set -o emacs;

# completion with some commands
complete -cf sudo
complete -cf man

set_prompt() {
  RCol='\033[0m'; Red='\033[31m'; Gre='\033[32m'; Yel='\033[33m'; Blu='\033[34m'
  startprompt="$(printf "\\xE2\\x94\\x8C\\xE2\\x94\\x80")"
  endprompt="$(printf "\\xE2\\x94\\x94\\xE2\\x94\\x80\\xE2\\x95\\xBC")"
  PS1="\\n\\r${RCol}${startprompt}[\`if [ \$? = 0 ]; then echo ${Gre}; else echo ${Red}; fi\`\\t\\[${RCol}\\] \\[${Blu}\\]\\h\\[${RCol}\\] \\[${Yel}\\]\\w\\[${RCol}\\]]\\n${endprompt} "
}

# set a restrictive umask
umask 077

# PATH
[ -f "${HOME}/.config/pathrc" ] && . "${HOME}/.config/pathrc"

# EDITOR
command -v nvim >/dev/null && export EDITOR="$(command -v nvim)"

# open man in neovim
command -v nvim >/dev/null && export MANPAGER="nvim -Rc 'set ft=man' -"

# let [Shift]+[Tab] cycle through all completions:
bind '"\033[Z": menu-complete'

##############
## HISTORY ###
##############

unset HISTFILESIZE
export HISTSIZE="10000"
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="fg:bg:&:[ ]*:exit:ls:clear:ll:cd:\\[A*:nvim:gs:gd:gf:gg:gl"
# Append to the history file, don't overwrite it
shopt -s histappend
# Save multi-line commands as one command
shopt -s cmdhist
# Enable incremental history search with up/down arrows (also Readline goodness)
# Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
bind '"\033[A": history-search-backward'
bind '"\033[B": history-search-forward'
bind '"\033[C": forward-char'
bind '"\033[D": backward-char'

#############
## ALIASES ##
#############

# remove all aliases
unalias -a

# some aliases
alias :q='exit'
alias todo='nvim -c "set ft=markdown" ${HOME}/.TODO.md'
alias grep='grep --color=always'
alias less='less -RX'
alias nraw='nvim -u NORC -c "setlocal syntax=off"'
alias nterm='nvim -c term'
alias :tabe='nvim'

if command -v exa >/dev/null; then
  alias ll='exa -gl --git --color=always'
  alias lla='exa -agl --git --color=always'
  alias llt='exa -gl --git -s modified --color=always'
else
  alias ll='ls -lhb --color'
fi

lll () {
    [ -z "$1" ] && t="." || t="$1";
    exa -gl --git --color=always "$t" | less -RX -R
}

command -v brightness >/dev/null && alias b='brightness'
command -v volume >/dev/null && alias v='volume'

# start cal on mondays
if command -v ncal >/dev/null; then
  alias cal="ncal -M -b"
else
  alias cal="cal -m"
fi

command -v trash-put >/dev/null && alias rr='trash-put'

# go to the root of the git repository
cdroot() {
  ! [ -e ".git" ] && [ "$(pwd)" != "/" ] && cd .. && cdroot || return 0
}

if command -v fzy >/dev/null; then
  # Required to refresh the prompt after fzy
  bind '"\er": redraw-current-line'
  bind '"\e^": history-expand-line'
  # CTRL-R - Paste the selected command from history into the command line
  bind '"\C-r": " \C-e\C-u\C-y\ey\C-u`HISTTIMEFORMAT= history | cut -c 8- | fzy`\e\C-e\er\e^"'
fi

# git aliases
if command -v git >/dev/null; then
  alias gl='git log --pretty=medium --abbrev-commit --date=relative --first-parent'
  alias gs='git status -sb'
  alias gf='git fetch -p --all'
  alias gd='git diff --color'
  alias gdd='git diff --color --staged'
  alias gg='git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all'

    # get number of commit last week/day for each author
    gp() {
      case "$1" in
        "day") age=$(( $(date +%s) - (60 * 60 * 24) ));;
        "month") age=$(( $(date +%s) - (60 * 60 * 24 * 30) ));;
        "week"|*) age=$(( $(date +%s) - (60 * 60 * 24 * 7) ));;
      esac
      (
      printf "commits,files,additions,deletions,author\\n"
      for name in $(git shortlog -se --all | sed -E 's/.*<(.*)>.*/\1/' | sort | uniq); do
        added="0"; deleted="0"; files="0"; count="0"
        for commit in $(git rev-list --no-merges --author="$name" --max-age="$age" --all); do
          count=$(( count + 1 ))
          stats="$(git diff --shortstat "$commit"^ "$commit" 2>/dev/null)"
          to_files=$(printf "%s" "$stats" | cut -d" " -f2)
          [ -n "$to_files" ] && files=$(( files + to_files ))
          to_add=$(printf "%s" "$stats" | cut -d" " -f5)
          [ -n "$to_add" ] && added=$(( added + to_add ))
          to_delete=$(printf "%s" "$stats" | cut -d" " -f7)
          [ -n "$to_delete" ] && deleted=$(( deleted + to_delete ))
        done
        if [ "$count" -gt 0 ]; then
          m_added=$(( added / count ))
          m_deleted=$(( deleted / count ))
          m_files=$(( files / count ))
          printf "%s,(%s) %s,(%s) %s,(%s) %s,%s\\n" "$count" "$m_files" "$files" "$m_added" "$added" "$m_deleted" "$deleted" "$name"
        fi
      done
      ) | column -t -s ','
    }
fi

if command -v openssl >/dev/null; then
  alias htpass='openssl passwd -apr1'
  checkCertificate() {
    if [ -f "$1" ]; then
      openssl x509 -enddate -noout -in "$1" | cut -d'=' -f2
    else
      openssl s_client -connect "$1":443 < /dev/null 2>/dev/null | openssl x509 -noout -enddate | cut -d'=' -f2
    fi
  }
  genSSHKey() {
    for arg in "$@"; do
      case "$arg" in
        --rsa)
          rsa="1";;
        --home)
          home="1";;
        *)
          user=$(printf "%s" "$arg" | cut -d'@' -f1)
          host=$(printf "%s" "$arg" | cut -sd'@' -f2 | cut -d':' -f1)
          port=$(printf "%s" "$arg" | cut -sd'@' -f2 | cut -sd':' -f2)
          ;;
      esac
    done
    [ -n "$host" ] && host="@$host"
    [ -n "$port" ] && port=":$port"
    [ "$rsa" = "1" ] && crypto="rsa" || crypto="ed25519"
    [ "$home" = "1" ] && cd "$HOME/.ssh"
    ssh-keygen -t "$crypto" -C "${user}${host}${port}-$(date -I)-${crypto}" -f "${user}${host}${port}" -a 100
    [ "$home" = "1" ] && cd -
  }
fi

if command -v youtube-dl >/dev/null; then
  alias ytmp3='youtube-dl -wi --extract-audio --audio-quality 3 --audio-format mp3'
  yt () {
      if echo "$1" | grep --color=always "https://.*youtu" > /dev/null; then
          min="$(get resolution | cut -d'x' -f2)";
          id="$(youtube-dl -F "$1" | tail -n +5 | grep -v "audio only" | awk 'int(substr($4, 1, length($4)-1)) >= '$min' { print $1}' | head -n1)";
          if [ -z $id ]; then
              id="best";
          fi;
          mpv --ytdl-format="$id+bestaudio" "$1";
      fi
  }
  ytclip () {
      ffmpeg -ss "$1" -i "$(youtube-dl -g "$3" | head -n1)" -t "$2" -f mp4 $(date +%Y-%m-%d-%H%M%S)-ytmp4.mp4
  }
  ytdl () {
      if echo "$1" | grep --color=always "https://.*youtu" > /dev/null; then
          min="$(get resolution | cut -d'x' -f2)";
          id="$(youtube-dl -F "$1" | tail -n +5 | grep -v "audio only" | awk 'int(substr($4, 1, length($4)-1)) >= '$min' { print $1}' | head -n1)";
          if [ -z $id ]; then
              id="best";
          fi;
          youtube-dl -f "$id+bestaudio" --merge-output-format mkv "$1";
      fi
  }
  ytgif () {
      ffmpeg -ss "$1" -t "$2" -i "$(youtube-dl -g "$3" | head -n1)" -filter_complex "[0:v] fps=12,scale=w=480:h=-1" -f gif $(date +%Y-%m-%d-%H%M%S)-ytgif.gif
  }
fi

# remove bare IPs from known_hosts
alias clean_known_host="sed -i '/^[0-9.]\\+ /d' $HOME/.ssh/known_hosts"

if command -v syncthing >/dev/null; then
  alias syncthing="syncthing -home $HOME/data/syncthing -gui-address 0.0.0.0:8384"
fi

if command -v socat >/dev/null; then
  isopen() {
    socat /dev/null "TCP4:$1,connect-timeout=2" 2>/dev/null
  }
fi

containers () {
    if command -v podman > /dev/null; then
        pgrm="podman";
    fi;

    if command -v docker > /dev/null; then
        pgrm="docker";
    fi;

    case "$1" in
      "clean")
        "$pgrm" stop $("$pgrm" ps -q)
        "$pgrm" rm $("$pgrm" ps -aq)
        "$pgrm" system prune -af
        "$pgrm" volume prune -f
        "$pgrm" rmi -af
        ;;
      "stats")
        "$pgrm" stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
        ;;
      *)
        echo "containers <clean|stats>"
        ;;
    esac
}

#bim() {
#    tmp=$(mktemp -d)
#    cd $tmp
#    ytmp3 "$1"
#    beet im $tmp
#}

# Secondary bashrc for local configurations
[ -f "${HOME}/.config/bashrc" ] && . "${HOME}/.config/bashrc"

# Prompt & Colors & Greetings
set_prompt
command -v gruvbox >/dev/null && gruvbox 2>/dev/null
command -v glimpse >/dev/null && glimpse 2>/dev/null
