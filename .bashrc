#!/bin/sh

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
startprompt="$(printf "\\xE2\\x94\\x8C\\xE2\\x94\\x80")"
endprompt="$(printf "\\xE2\\x94\\x94\\xE2\\x94\\x80\\xE2\\x95\\xBC")"
PS1="\\n\\r${RCol}${startprompt}[\`if [ \$? = 0 ]; then echo ${Gre}; else echo ${Red}; fi\`\\t\\[${RCol}\\] \\[${Blu}\\]\\h\\[${RCol}\\] \\[${Yel}\\]\\w\\[${RCol}\\]]\\n${endprompt} "

# display gruvbox colors event in a tty
gruvbox() {
    # if we are in a tty
    if [ "$TERM" = "linux" ]; then
        printf "\033]P0282828" #black
        printf "\033]P1cc241d" #red
        printf "\033]P298971a" #green
        printf "\033]P3d79921" #yellow
        printf "\033]P4458588" #blue
        printf "\033]P5b16286" #purple
        printf "\033]P6689d6a" #aqua
        printf "\033]P7a89984" #grey
        printf "\033]P8928374" #boldgrey
        printf "\033]P9fb4934" #boldred
        printf "\033]PAb8bb26" #boldgreen
        printf "\033]PBfabd2f" #boldyellow
        printf "\033]PC83a598" #boldblue
        printf "\033]PDd3869b" #boldpurple
        printf "\033]PE8ec07c" #boldaqua
        printf "\033]PFebdbb2" #fg
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

# enables user services and start them
if [ -n "$(command -v systemctl 2>/dev/null)" ]; then
    if ! [ -h ${HOME}/.config/systemd/user/default.target.wants/ssh-agent.service ]
    then
        systemctl --user enable ssh-agent.service
        systemctl --user start ssh-agent.service
    fi
fi

# set a restrictive umask
umask 077

# Automatically trim long paths in the prompt (requires Bash 4.x)
export PROMPT_DIRTRIM=2

# (bash 4+) enable recursive glob for grep, rsync, ls, ...
shopt -s globstar &> /dev/null

# PATH
[ -d "${HOME}/bin" ] && export PATH="${PATH}:${HOME}/bin"
[ -d "${HOME}/.yarn/bin" ] && export PATH="${PATH}:${HOME}/.yarn/bin"
[ -d "${HOME}/.cargo/bin" ] && export PATH="${PATH}:${HOME}/.cargo/bin"
[ -f "${HOME}/.fzf.bash" ] && . "${HOME}/.fzf.bash"
[ -n "$(command -v nvim)" ] && export EDITOR="/usr/bin/nvim"

# completion with sudo
complete -cf sudo

# open man in neovim
# export MANPAGER="less"
export MANPAGER="nvim -c 'set ft=man' -"

# set history variables
unset HISTFILESIZE
export HISTSIZE="10000"
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="fg:bg:&:[ ]*:exit:ls:clear:ll:cd:\\[A*:nvim:gs:gd:gf:gg:gl:systemctl poweroff:shutdown*"
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
alias grep='grep --color=always'
alias less='less -R'
alias emerge='emerge --color y'

# git aliases
if [ -n "$(command -v git 2>/dev/null)" ]; then
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
            "day")
                age=$(( $(date +%s) - (60 * 60 * 24) ))
                ;;
            "week")
                age=$(( $(date +%s) - (60 * 60 * 24 * 7) ))
                ;;
            "month")
                age=$(( $(date +%s) - (60 * 60 * 24 * 30) ))
                ;;
            *)
                age=$(( $(date +%s) - (60 * 60 * 24 * 7) ))
                ;;
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
                printf "%s,(%s) %s, (%s) %s,(%s) %s,%s\\n" "$count" "$m_files" "$files" "$m_added" "$added" "$m_deleted" "$deleted" "$name"
            fi
        done
        ) | column -t -s ','
    }

    alias gp='git_pulse'

    if [ -n "$(command -v git_forest 2>/dev/null)" ]; then
        alias gg='git_forest --all | less'
    else
        alias gg='git log --graph --abbrev-commit --decorate --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)" --all'
    fi

    if [ -n "$(command -v diff-so-fancy 2>/dev/null)" ]; then
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
        alias gd='git diff --color --color-moved'
    fi
fi

[ -n "$(command -v trash-put 2>/dev/null)" ] && alias rr='trash-put'

[ -n "$(command -v wifi-menu 2>/dev/null)" ] && alias wifi='sudo wifi-menu'

if [ -n "$(command -v curl 2>/dev/null)" ]; then
    ww() {
        curl -s "wttr.in/$1"
    }
fi

if [ -n "$(command -v exa 2>/dev/null)" ]; then
    alias ll='exa -gl --git'
    alias lla='exa -agl --git'
    alias llt='exa -gl --git -s modified'
else
    alias ll='ls -lhb --color'
    alias lla='ls -alhb --color'
    alias llt='ls -lhbt --color'
fi

[ -n "$(command -v youtube-dl 2>/dev/null)" ] && alias ytmp3='youtube-dl -wi --extract-audio --audio-quality 3 --audio-format mp3'
[ -n "$(command -v mpv 2>/dev/null)" ] && alias play="mpv --no-video --loop-playlist"

# TODO: find a more reliable function that proposes all bluetooth devices
# probably a separated script
if [ -n "$(command -v bluetoothctl 2>/dev/null)" ]; then
    bt() {
        if [ "$1" = "on" ]; then
            (
            sudo rfkill block bluetooth
            sleep 1
            sudo rfkill unblock bluetooth
            printf "power off" | bluetoothctl
            sleep 1
            printf "power on" | bluetoothctl
            sleep 1
            printf "agent off" | bluetoothctl
            sleep 1
            printf "agent on" | bluetoothctl
            sleep 1
            printf "disconnect 10:4F:A8:BB:0B:1C" | bluetoothctl
            sleep 1
            printf "connect 10:4F:A8:BB:0B:1C" | bluetoothctl
            ) >/dev/null 2>/dev/null
        else
            (
            printf "disconnect 10:4F:A8:BB:0B:1C" | bluetoothctl
            printf "agent off" | bluetoothctl
            printf "power off" | bluetoothctl
            sudo rfkill block bluetooth
            ) >/dev/null 2>/dev/null
        fi
    }
fi

if [ -n "$(command -v openssl 2>/dev/null)" ]; then
    alias htpass='openssl passwd -apr1'
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

extract() {
    if [ -z "$1" ]; then
        # display usage if no parameters given
        printf "Usage: extract <path/file_name>.<zip|rar|bz2|gz|tar|tbz2|tgz|Z|7z|xz|ex|tar.bz2|tar.gz|tar.xz>\\n"
        printf "       extract <path/file_name_1.ext> [path/file_name_2.ext] [path/file_name_3.ext]\\n"
        return 1
    fi
    for n in "$@"; do
        if [ -f "$n" ]; then
            case "${n%,}" in
                *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) tar xvf "$n" ;;
                *.lzma) unlzma ./"$n" ;;
                *.bz2) bunzip2 ./"$n" ;;
                *.rar) unrar x -ad ./"$n" ;;
                *.gz) gunzip ./"$n" ;;
                *.zip) unzip ./"$n" ;;
                *.z) uncompress ./"$n" ;;
                *.7z|*.arj|*.cab|*.chm|*.deb|*.dmg|*.iso|*.lzh|*.msi|*.rpm|*.udf|*.wim|*.xar) 7z x ./"$n" ;;
                *.xz) unxz ./"$n" ;;
                *.exe) cabextract ./"$n" ;;
                *)
                    printf "extract: '%s' - unknown archive method\\n" "$n"
                    return 1
                    ;;
            esac
        else
            printf "'%s' - file does not exist\\n" "$n"
            return 1
        fi
    done
}

gruvbox

# Greetings
[ -n "$(command -v greeting 2>/dev/null)" ] && greeting 2>/dev/null
