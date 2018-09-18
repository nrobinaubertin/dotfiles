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

# completion with sudo
complete -cf sudo

set_prompt() {
    # some colors
    RCol='\033[0m'
    Red='\033[31m';
    Gre='\033[32m';
    Yel='\033[33m';
    Blu='\033[34m';

    # custom prompt
    startprompt="$(printf "\\xE2\\x94\\x8C\\xE2\\x94\\x80")"
    if command -v get >/dev/null; then
        power="$(get power | tr -d "a-z/%")"
        case $power in
            ""|*[!0-9]*) batteryalert="" ;;
            *)
                if [ "10" -gt "$power" ]; then
                    batteryalert="${Red} BATTERY LOW !${RCol}"
                else
                    batteryalert=""
                fi
                ;;
        esac
    fi
    endprompt="$(printf "\\xE2\\x94\\x94\\xE2\\x94\\x80\\xE2\\x95\\xBC")"
    PS1="\\n\\r${RCol}${startprompt}[\`if [ \$? = 0 ]; then echo ${Gre}; else echo ${Red}; fi\`\\t\\[${RCol}\\] \\[${Blu}\\]\\h\\[${RCol}\\] \\[${Yel}\\]\\w\\[${RCol}\\]]${batteryalert}\\n${endprompt} "
}

# display gruvbox colors event in a tty
gruvbox() {
    # if we are in a tty
    if [ "$TERM" = "linux" ]; then
        if [ "$1" = "light"]; then
            printf "\033]P0fbf1c7" #bg
            printf "\033]P77c6f64" #grey
            printf "\033]P99d0006" #boldred
            printf "\033]PA79740e" #boldgreen
            printf "\033]PBb57614" #boldyellow
            printf "\033]PC076678" #boldblue
            printf "\033]PD8f3f71" #boldpurple
            printf "\033]PE427b58" #boldaqua
            printf "\033]PF3c3836" #fg
        else
            printf "\033]P0282828" #bg
            printf "\033]P7a89984" #grey
            printf "\033]P9fb4934" #boldred
            printf "\033]PAb8bb26" #boldgreen
            printf "\033]PBfabd2f" #boldyellow
            printf "\033]PC83a598" #boldblue
            printf "\033]PDd3869b" #boldpurple
            printf "\033]PE8ec07c" #boldaqua
            printf "\033]PFebdbb2" #fg
        fi
        printf "\033]P1cc241d" #red
        printf "\033]P298971a" #green
        printf "\033]P3d79921" #yellow
        printf "\033]P4458588" #blue
        printf "\033]P5b16286" #purple
        printf "\033]P6689d6a" #aqua
        printf "\033]P8928374" #boldgrey

        clear #for background artifacting
    else
        printf "\033]4;236;rgb:32/30/2f\033\\"
        printf "\033]4;234;rgb:1d/20/21\033\\"
        printf "\033]4;235;rgb:28/28/28\033\\"
        printf "\033]4;237;rgb:3c/38/36\033\\"
        printf "\033]4;239;rgb:50/49/45\033\\"
        printf "\033]4;241;rgb:66/5c/54\033\\"
        printf "\033]4;243;rgb:7c/6f/64\033\\"
        printf "\033]4;244;rgb:92/83/74\033\\"
        printf "\033]4;245;rgb:92/83/74\033\\"
        printf "\033]4;228;rgb:f2/e5/bc\033\\"
        printf "\033]4;230;rgb:f9/f5/d7\033\\"
        printf "\033]4;229;rgb:fb/f1/c7\033\\"
        printf "\033]4;223;rgb:eb/db/b2\033\\"
        printf "\033]4;250;rgb:d5/c4/a1\033\\"
        printf "\033]4;248;rgb:bd/ae/93\033\\"
        printf "\033]4;246;rgb:a8/99/84\033\\"
        printf "\033]4;167;rgb:fb/49/34\033\\"
        printf "\033]4;142;rgb:b8/bb/26\033\\"
        printf "\033]4;214;rgb:fa/bd/2f\033\\"
        printf "\033]4;109;rgb:83/a5/98\033\\"
        printf "\033]4;175;rgb:d3/86/9b\033\\"
        printf "\033]4;108;rgb:8e/c0/7c\033\\"
        printf "\033]4;208;rgb:fe/80/19\033\\"
        printf "\033]4;88;rgb:9d/00/06\033\\"
        printf "\033]4;100;rgb:79/74/0e\033\\"
        printf "\033]4;136;rgb:b5/76/14\033\\"
        printf "\033]4;24;rgb:07/66/78\033\\"
        printf "\033]4;96;rgb:8f/3f/71\033\\"
        printf "\033]4;66;rgb:42/7b/58\033\\"
        printf "\033]4;130;rgb:af/3a/03\033\\"
    fi
}

set_prompt
gruvbox

# set a restrictive umask
umask 077

# enables user services and start them
if command -v systemctl >/dev/null; then
    if ! [ -h ${HOME}/.config/systemd/user/default.target.wants/ssh-agent.service ]
    then
        systemctl --user enable ssh-agent.service
        systemctl --user start ssh-agent.service
    fi
fi

# PATH
. "${HOME}/.config/pathrc"

# FZF and EDITOR
[ -f "${HOME}/.fzf.bash" ] && . "${HOME}/.fzf.bash"
command -v nvim >/dev/null && export EDITOR="/usr/bin/nvim"

# open man in neovim
export MANPAGER="nvim -Rc 'set ft=man' -"

##############
## HISTORY ###
##############

unset HISTFILESIZE
export HISTSIZE="10000"
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="fg:bg:&:[ ]*:exit:ls:clear:ll:cd:\\[A*:nvim:gs:gd:gf:gg:gl"
export HISTTIMEFORMAT='%F %T '
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
alias todo='nvim ${HOME}/data/niels-data/.TODO'
alias grep='grep --color=always'
alias less='less -RX'
alias emerge='emerge --color y'

[ -n "$(command -v trash-put 2>/dev/null)" ] && alias rr='trash-put'
[ -n "$(command -v bat 2>/dev/null)" ] && alias cat='bat'
[ -n "$(command -v wifi-menu 2>/dev/null)" ] && alias wifi='sudo wifi-menu'
[ -n "$(command -v youtube-dl 2>/dev/null)" ] && alias ytmp3='youtube-dl -wi --extract-audio --audio-quality 3 --audio-format mp3'
[ -n "$(command -v mpv 2>/dev/null)" ] && alias play="mpv --no-video --loop-playlist"

# git aliases
if command -v git >/dev/null; then
    # git autocompletion file
    if ! [ -f "${HOME}/.local/share/git/git-completion.bash" ]; then
        mkdir -p "${HOME}/.local/share/git/"
        curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o "${HOME}/.local/share/git/git-completion.bash" 2>/dev/null
        chmod +x "${HOME}/.local/share/git/git-completion.bash"
    fi
    . "${HOME}/.local/share/git/git-completion.bash" 2>/dev/null

    alias gl='git log --pretty=medium --abbrev-commit --date=relative'
    alias gs='git status -sb'
    alias gf='git fetch -p --all'
    alias gd='git diff --color --color-moved'
    alias gg='git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all'

    # get stats of a git repo
    git_stats() {
        (
        head=$(git ls-files | while read -r f; do git blame --line-porcelain "$f" | grep '^author-mail '; done | sort -f | uniq -ic | sort -n | tr -d '<>' | awk '{print $1, $3}')
        printf "head,commits,inserted,deleted,author\\n"
        for author in $(git log --pretty="%ce" | sort | uniq)
        do
            head_author=$(echo "$head" | grep "$author" | cut -d' ' -f1)
            stat=$(git log --shortstat --author "$author" -i 2> /dev/null | grep -E 'files? changed' | awk 'BEGIN{commits=0;inserted=0;deleted=0} {commits+=1; if($5!~"^insertion") { deleted+=$4 } else { inserted+=$4; deleted+=$6 } } END {print commits, ",", inserted, ",", deleted}')
            printf "%s,%s,%s\\n" "$head_author" "$stat" "$author"
        done
        ) | column -t -s ','
    }

    # get number of commit last week/day for each author
    git_pulse() {
        case "$1" in
            "day") age=$(( $(date +%s) - (60 * 60 * 24) ));;
            "month") age=$(( $(date +%s) - (60 * 60 * 24 * 30) ));;
            "week"|*) age=$(( $(date +%s) - (60 * 60 * 24 * 7) ));;
        esac
        (
        printf "commits,files,additions,deletions,author\\n"
        for name in $(git shortlog -se --all | sed -E 's/.*<(.*)>.*/\1/' | sort | uniq)
        do
            count=$(git rev-list --no-merges --author="$name" --max-age="$age" --count --all)
            if [ "$count" -gt 0 ]; then
                added="0"
                deleted="0"
                files="0"
                for commit in $(git rev-list --no-merges --author="$name" --max-age="$age" --all)
                do
                    if [ -n "$commit" ]; then
                        to_files=$(git diff --shortstat "$commit"^ "$commit" 2>/dev/null | cut -d" " -f2)
                        if [ -n "$to_files" ]; then
                            files=$(( files + to_files ))
                        fi
                        to_add=$(git diff --shortstat "$commit"^ "$commit" 2>/dev/null | cut -d" " -f5)
                        if [ -n "$to_add" ]; then
                            added=$(( added + to_add ))
                        fi
                        to_delete=$(git diff --shortstat "$commit"^ "$commit" 2>/dev/null | cut -d" " -f7)
                        if [ -n "$to_delete" ]; then
                            deleted=$(( deleted + to_delete ))
                        fi
                    fi
                done
                m_added=$(( added / count ))
                m_deleted=$(( deleted / count ))
                m_files=$(( files / count ))
                printf "%s,(%s) %s,(%s) %s,(%s) %s,%s\\n" "$count" "$m_files" "$files" "$m_added" "$added" "$m_deleted" "$deleted" "$name"
            fi
        done
        ) | column -t -s ','
    }

    alias gp='git_pulse'
fi

if command -v curl >/dev/null; then
    ww() {
        curl -s "wttr.in/$1" | head -n -3
    }
fi

if command -v exa >/dev/null; then
    alias ll='exa -gl --git --color=always'
    alias lll='exa -gl --git --color=always | less -R'
    alias lla='exa -agl --git --color=always'
    alias llt='exa -gl --git -s modified --color=always'
else
    alias ll='ls -lhb --color'
    alias lll='ls -lhb --color | less -R'
    alias lla='ls -alhb --color'
    alias llt='ls -lhbt --color'
fi

if command -v openssl >/dev/null; then
    alias htpass='openssl passwd -apr1'
    checkCertificate() {
        openssl s_client -connect "$1":443 < /dev/null 2>/dev/null | openssl x509 -noout -enddate | cut -d'=' -f2
    }
    genSSHKey() {
        user=$(printf "%s" "$1" | cut -d'@' -f1)
        host=$(printf "%s" "$1" | cut -d'@' -f2 | cut -d':' -f1)
        # port=$(printf "%s" "$1" | cut -d'@' -f2 | cut -d':' -f2)
        ssh-keygen -t ed25519 -C "$user@$host-$(date -I)" -f "$HOME/.ssh/id_ed25519.$user@$host" -a 100
    }
fi

# go to the root of the git repository
cdroot() {
    ! [ -d ".git" ] && [ "$(pwd)" != "/" ] && cd .. && cdroot
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

# Greetings
[ -n "$(command -v greeting 2>/dev/null)" ] && greeting 2>/dev/null
