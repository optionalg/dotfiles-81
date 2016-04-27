# sys
alias s="sudo"
alias se="sudo -e"

# permissions
alias chmox="chmod +x"
alias mine="s chown $(echo $USER):users"
alias all="mine -R *"

# operations
alias mount="s mount"
alias umount="s umount"

alias mv="mv -f"
alias cp="cp -rf"
alias rm="rm -rf"
alias mmv="noglob zmv -W"
alias rsync="rsync -av"

alias l="ls"
alias la="ls -A"
alias lr="ls -R"
alias lra="ls -RA"

# normal ls colouring generally sucks in listview
type ccze 2>&1 > /dev/null && {
    ll() {
        ls -lh "$@" | ccze -A
    }

    lla() {
        ls -lhA "$@" | ccze -A
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
        ls -lhsA "$@" | ccze -A
    }

    llta() {
        ls -lhtA "$@" | ccze -A
    }

    llxa() {
        ls -lhXA "$@" | ccze -A
    }
} || {
    alias ll="ls -lh"
    alias lla="ls -lhA"
    alias lls="ls -lhs"
    alias llt="ls -lht"
    alias llx="ls -lhX"
    alias llsa="ls -lhsA"
    alias llta="ls -lhtA"
    alias llxa="ls -lhXA"
}

alias sz="du -hs"
alias sza="clear; sz && sz * | sort -hr"

alias szsh="source ~/.zshrc"
alias sxrdb="xrdb ~/.Xresources"

# apps
alias todo="$VISUAL ~/.todo.md"

# games
alias steamcfg="WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=~/.wine-steam winecfg"
alias steamtricks="WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=~/.wine-steam winetricks"
alias steamwine="WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=~/.wine-steam wine \
~/.wine-steam/drive_c/Program\ Files/Steam/Steam.exe"

alias ftl="RWD=$PWD; cd $HOME/games/FTL && ./FTL 2>&1 > /dev/null &!; cd $RWD"
alias rayman='env WINEPREFIX="/home/fyr/.wine-rayman" wine \
C:\\\\windows\\\\command\\\\start.exe /Unix \
/home/fyr/.wine-rayman/dosdevices/c:/users/Public/Desktop/Rayman\ Forever.lnk'

eliteforce() {
    cd /home/fyr/.wine-eliteforce/drive_c/Program\ Files/Raven/Star\ Trek\ Voyager\ Elite\ Force/
    WINEDEBUG=-all WINEARCH=win32 WINEPREFIX=~/.wine-eliteforce wine ./stvoy.exe
}

# net
alias hn="hostname"
alias tn="transmission-remote-cli"
alias yt="youtube-dl -x -o \"%(title)s.%(ext)s\""
alias external="curl -s icanhazip.com"
alias internal="ip a | grep -w \"inet\" | awk '/192/ {print \$2}' | cut -d'/' -f 1"

# dtach / tmux
alias dz="dtach -A /tmp/zsh -z zsh"
alias irc="dtach -A /tmp/irc -z weechat"
alias gog="dtach -A /tmp/gogs -z /builds/gogs/gogs"
alias steam="dtach -A /tmp/steam -z steam"

# fonts
alias lemon="printf '\e]710;%s\007' \"-benis-lemon-*-*-*-*-*-*-*-*-*-*-*-*\""
alias edges="printf '\e]710;%s\007' \"-artwiz-edges-*-*-*-*-*-*-*-*-*-*-*-*\""

# ascii art
alias tits="curl -sL z3bra.org/tits"
alias unix="printf '%s\n' \"\$(curl -sL git.io/unix)\""
alias taco="printf '%s\n' \"\$(curl -sL git.io/taco)\""
alias pizza="printf '%s\n' \"\$(curl -sL git.io/pizza)\""
alias nixers="curl -sL https://wildefyr.net/media/nixers"

# misc.
alias motd="cat /etc/motd"
alias issue="cat /etc/issue"
alias happy="toilet -f term -w 200 -t --gay"
alias metal="toilet -f term -w 200 -t --metal"
alias gibberish="metal < /dev/urandom"
alias snake="terminibbles -d 3 -q"
alias matrix="cmatrix -ab -u 1"
alias engage="sox -c 2 -n synth whitenoise band -n 100 24 band -n 300 100 \
gain +4 synth whitenoise lowpass -1 100 lowpass -1 100 lowpass -1 100 gain +2"
alias starwars="telnet towel.blinkenlights.nl"
