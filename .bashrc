#!/bin/bash

# do not continue if we are not in a bash shell
[ -z "$BASH_VERSION" ] && return

# do not continue if we are not running interactively
[ -z "$PS1" ] && return

# some colors
RCol='\033[0m'
Red='\033[31m';
Gre='\033[32m';
Yel='\033[33m';
Blu='\033[34m';

# custom prompt
PS1="\n\r${RCol}┌─[\`if [ \$? = 0 ]; then echo ${Gre}; else echo ${Red}; fi\`\t\[${RCol}\] \[${Blu}\]\h\[${RCol}\] \[${Yel}\]\w\[${RCol}\]]\n└─╼ "

# attach/start tmux
start_tmux() {
    # If not running interactively, do not do anything
    [[ $- != *i* ]] && return
    # If tmux exists on the system, attach or create session
    if [[ -z "$TMUX" ]] && [[ -n $(which tmux) ]] 
    then
        t=$(tmux has-session 2>&1)
        if [[ -z "$t" ]]
        then exec tmux -2 attach
        else exec tmux -2 new
        fi
    fi
}

# display gruvbox colors event in a tty
gruvbox() {
    # if we are in a tty
    if [ "$TERM" = "linux" ]; then
        echo -en "\e]P0282828" #black
        echo -en "\e]P1cc241d" #red
        echo -en "\e]P298971a" #green
        echo -en "\e]P3d79921" #yellow
        echo -en "\e]P4458588" #blue
        echo -en "\e]P5b16286" #purple
        echo -en "\e]P6689d6a" #aqua
        echo -en "\e]P7a89984" #grey
        echo -en "\e]P8928374" #boldgrey
        echo -en "\e]P9fb4934" #boldred
        echo -en "\e]PAb8bb26" #boldgreen
        echo -en "\e]PBfabd2f" #boldyellow
        echo -en "\e]PC83a598" #boldblue
        echo -en "\e]PDd3869b" #boldpurple
        echo -en "\e]PE8ec07c" #boldaqua
        echo -en "\e]PFebdbb2" #fg
        clear #for background artifacting
    fi
}

# Automatically trim long paths in the prompt (requires Bash 4.x)
export PROMPT_DIRTRIM=2

# (bash 4+) enable recursive glob for grep, rsync, ls, ...
shopt -s globstar &> /dev/null

# PATH
[ -d "${HOME}/bin" ] && export PATH="${PATH}:${HOME}/bin"
[ -d "${HOME}/.yarn/bin" ] && export PATH="${PATH}:${HOME}/.yarn/bin"
[ -d "${HOME}/.cargo/bin" ] && export PATH="${PATH}:${HOME}/.cargo/bin"
[ -f "${HOME}/.fzf.bash" ] && source "${HOME}/.fzf.bash"

if [ -n "$(which nvim)" ]
then
    export EDITOR="/usr/bin/nvim"
fi

# completion with sudo
complete -cf sudo

# open man in neovim
command -v nvim > /dev/null 2>&1 && export MANPAGER="nvim '+set ft=man' -"

# set pager conf
export LESS_TERMCAP_mb=$'\033[01;31m'
export LESS_TERMCAP_md=$'\033[01;33m'
export LESS_TERMCAP_me=$'\033[0m'
export LESS_TERMCAP_se=$'\033[0m'
export LESS_TERMCAP_so=$'\033[01;44;37m'
export LESS_TERMCAP_ue=$'\033[0m'
export LESS_TERMCAP_us=$'\033[01;37m'
export LESS="-RI"

# set history variables
unset HISTFILESIZE
export HISTSIZE="10000"
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="fg:bg:&:[ ]*:exit:ls:history:clear:ll:cd:\[A*"
export HISTTIMEFORMAT='%F %T '

# Enable incremental history search with up/down arrows (also Readline goodness)
# Learn more about this here: http://codeinthehole.com/writing/the-most-important-command-line-tip-incremental-history-searching-with-inputrc/
bind '"\033[A": history-search-backward'
bind '"\033[B": history-search-forward'
bind '"\033[C": forward-char'
bind '"\033[D": backward-char'

# some aliases
alias :q='exit'
alias tmux='tmux -2'
alias todo='nvim ${HOME}/.TODO'

# git aliases
if [ -n "$(which git 2>/dev/null)" ]
then
    alias gl='git log --pretty=medium --abbrev-commit --date=relative'
    alias gs='git status -sb'

    # get stats of a git repo
    git-stats() {

        (
        head=$(git ls-files | while read -r f; do git blame --line-porcelain "$f" | grep '^author-mail '; done | sort -f | uniq -ic | sort -n | tr -d '<>' | awk '{print $1, $3}')
            printf "head,commits,inserted,deleted,author\n"
            for author in $(git log --pretty="%ce" | sort | uniq)
            do
                head_author=$(echo "$head" | grep "$author" | cut -d' ' -f1)
                stat=$(git log --shortstat --author "$author" -i 2> /dev/null | grep -E 'files? changed' | awk 'BEGIN{commits=0;inserted=0;deleted=0} {commits+=1; if($5!~"^insertion") { deleted+=$4 } else { inserted+=$4; deleted+=$6 } } END {print commits, ",", inserted, ",", deleted}')
                printf "%s,%s,%s\n" "$head_author" "$stat" "$author"
            done
        ) | column -t -s ','
        
    }

    # get number of commit last week/day for each author
    git-pulse() {
        if [ "$1" == "today" ]
        then
            age=$(( $(date +%s) - (60 * 60 * 24) ))
        else
            age=$(( $(date +%s) - (60 * 60 * 24 * 7) ))
        fi
        (
            echo -e "commits,additions,deletions,author\n"
            for name in $(git log --pretty="%ce" | sort | uniq)
            do
                count=$(git rev-list --no-merges --author="$name" --max-age="$age" --count --all)
                if [ "$count" -gt 0 ]
                then
                    added="0"
                    deleted="0"
                    for commit in $(git rev-list --no-merges --author="$name" --max-age="$age" --all)
                    do
                        if [ -n "$commit" ]
                        then
                            to_add=$(git diff --shortstat "$commit"^ "$commit" | cut -d" " -f5)
                            if [ -n "$to_add" ]
                            then
                                added=$(( added + to_add ))
                            fi
                            to_delete=$(git diff --shortstat "$commit"^ "$commit" | cut -d" " -f7)
                            if [ -n "$to_delete" ]
                            then
                                deleted=$(( deleted + to_delete ))
                            fi
                        fi
                    done
                    echo -e "$count,$added,$deleted,$name\n"
                fi
            done
        ) | column -t -s ','
    }

    alias gp='git-pulse'

    if [ -n "$(which git-forest 2>/dev/null)" ]
    then
        alias gf='git-forest --all | less'
    else
        alias gf='git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all'
    fi

    if [ -n "$(which diff-so-fancy 2>/dev/null)" ]
    then
        gd() {
            if [ -z "$1" ]
            then
                target="."
            else
                target="$1"
            fi
            git diff --color "$target" | diff-so-fancy | less
        }
    else
        alias gd='git diff --color'
    fi
fi

if [ -n "$(which trash-put 2>/dev/null)" ]
then
    alias rr='trash-put'
fi

if [ -n "$(which wifi-menu 2>/dev/null)" ]
then
    alias wifi='sudo wifi-menu'
fi

if [ -n "$(which curl 2>/dev/null)" ]
then
    ww() {
        curl -s "wttr.in/$1"
    }
fi

if [ -n "$(which exa 2>/dev/null)" ]
then
    alias ll='exa -gl --git'
    alias lla='exa -agl --git'
    alias llt='exa -gl --git -s modified'
else
    alias ll='ls -lhb --color'
    alias lla='ls -alhb --color'
    alias llt='ls -lhbt --color'
fi

if [ -n "$(which youtube-dl 2>/dev/null)" ]
then
    alias ytmp3='youtube-dl --extract-audio --audio-quality 3 --audio-format mp3'
fi

if [ -n "$(which mpv 2>/dev/null)" ]
then
    alias play="mpv --no-video --loop-playlist"
fi

if [ -n "$(which bluetoothctl 2>/dev/null)" ]
then
    connectAudioFunction() {
rfkill unblock bluetooth
bluetoothctl << EOF
power off
EOF
sleep 1
bluetoothctl << EOF
power on
agent on
EOF
sleep 1
bluetoothctl << EOF
connect 10:4F:A8:BB:0B:1C
EOF
    }

    # alias bt="connectAudioFunction > /dev/null && connectAudioFunction > /dev/null"
    alias bt="connectAudioFunction > /dev/null"
fi

# go to the root of the git repository
cdroot() {
    if ! [ -d ".git" ] && [ "$(pwd)" != "/" ]
    then
        cd ..
        cdroot
    fi
}

# get number of files for each extension in a dir
scan() {
    find "$1" -type f -not -path '*/\.*' 2>/dev/null | awk -F . '{print $NF}' | grep -v "/" | sort | uniq -c | sort -t " " -k 1 -g -r
}

# get md5sum of directory
md5dirsum() {
    cd "$1" || exit
    find . -type f -print0 | sort -z | uniq -z | xargs -0 -n 1 md5sum | sort | md5sum
    cd - >/dev/null || exit
}

gruvbox
if [ -z "$(pgrep tmux)" ]
then
    start_tmux
fi

# Greetings
if [ -n "$(which greeting 2>/dev/null)" ]
then
    greeting 2>/dev/null
fi
