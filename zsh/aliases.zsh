# sys
alias s="sudo"
alias se="sudo -e"

alias sys="watch -n 1 -p \"df -h | grep '/dev/' | sort -h && printf '\n' && \
free -h && printf '\n' && ps xgf | sed '1d; s/--type.*//'\""

# permissions
alias chmox="chmod +x"
alias mine="s chown $(echo $USER):users" alias all="mine -R *"

# operations
alias mount="s mount"
alias umount="s umount"

alias mv="mv -f"
alias cp="cp -rf"
alias rm="rm -rf"
alias mmv="noglob zmv -W"
alias rsync="rsync -arvp --progress -h"

alias l="ls"
alias la="ls -a"

# normal ls colouring generally sucks in listview
type ccze 2>&1 > /dev/null && {
    ll() {
        ls -lh "$@" | ccze -A
    }

    lla() {
        ls -lha "$@" | ccze -A
    }

    lls() {
        ls -lhs "$@" | ccze -A
    }

    llt() {
        ls -lht "$@" | ccze -A
    }

    llx() {
        ls -lhX "$@" | ccze -A
    }

    llsa() {
        ls -lhsa "$@" | ccze -A
    }

    llta() {
        ls -lhta "$@" | ccze -A
    }

    llxa() {
        ls -lhXa "$@" | ccze -A
    }
} || {
    alias ll="ls -lh"
    alias lla="ls -lha"
    alias lls="ls -lhs"
    alias llt="ls -lht"
    alias llx="ls -lhX"
    alias llsa="ls -lhsa"
    alias llta="ls -lhta"
    alias llxa="ls -lhXa"
}

alias sz="du -hs"
alias t="clear; sz; tree"
alias sza="sz && sz * | sort -hr"
alias szt="t -h --du --sort=size"

alias szsh="source ~/.zshrc"
alias sxrdb="xrdb ~/.Xresources"

# wine
alias steamwine="WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=~/.wine-steam wine \
~/.wine-steam/drive_c/Program\ Files/Steam/Steam.exe"
alias steamtricks="WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=~/.wine-steam winetricks"
alias steamcfg="WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=~/.wine-steam cfg"

# net
alias hn="hostname"
alias tn="transmission-remote-cli"
alias yt="youtube-dl -x -o \"%(title)s.%(ext)s\""
alias external="curl -s icanhazip.com"
alias internal="ip a | grep -w \"inet\" | awk '/192/ {print \$2}' | cut -d'/' -f 1"

# dtach / tmux
alias irc="dtach -A /tmp/irc -z weechat"
alias gog="dtach -A /tmp/gogs -z /builds/gogs/gogs"
alias mux="tmux attach || tmux new"
alias dzsh="dtach -A /tmp/zsh -z zsh"
alias steam="dtach -A /tmp/steam -z steam"

# misc.
alias motd="cat /etc/motd"
alias issue="cat /etc/issue"
alias happy="toilet -f term -w 200 -t --gay"
alias metal="toilet -f term -w 200 -t --metal"
alias gibberish="metal < /dev/urandom"
alias snake="terminibbles -d 3 -q"
alias matrix="cmatrix -ab -u 1"
alias makeitso="sox -c 2 -n synth whitenoise band -n 100 24 band -n 300 100 \
gain +4 synth whitenoise lowpass -1 100 lowpass -1 100 lowpass -1 100 gain +2"

# ascii art
alias tits="curl -sL z3bra.org/tits"
alias unix="printf '%s\n' \"\$(curl -sL git.io/unix)\""
alias taco="printf '%s\n' \"\$(curl -sL git.io/taco)\""
alias pizza="printf '%s\n' \"\$(curl -sL git.io/pizza)\""
alias nixers="curl -sL https://wildefyr.net/media/nixers"
