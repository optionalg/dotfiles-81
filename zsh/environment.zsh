DOTS="$HOME/.dotfiles"
alias hot="$EDITOR $DOTS/sxhkd/*"

LOCALE="$HOME/.zsh/locale.sh"
test -f "$LOCALE" && . $LOCALE

umask 022

unset TERMCAP
unset MANPATH

# who needs C-q and C-s nowadays?
stty -ixon
stty start undef

EXECPATHS="\
/bin
/sbin
/usr/bin
/opt/bin
/usr/sbin
/opt/sbin
$DOTS/bin
$HOME/.fzf/bin
/builds/go/bin
/usr/local/bin"

printf '%s\n' "$EXECPATHS" | while read -r EXECPATH; do
    test -d "$EXECPATH" && export PATH="$PATH:$EXECPATH"
done

unset EXECPATH

# compiling
export CC="/usr/bin/gcc"
export CXX="/usr/bin/g++"
export GOPATH="/builds/go"

# misc.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_RUNTIME_DIR="/tmp/runtime-wildefyr"

export BIN="$DOTS/bin"
export BUL="$HOME/.builds"
export DWN="$HOME/downloads"
export MUS="$HOME/files/music"
export IMG="$HOME/files/pictures"

export IMGVIEW="mpv --really-quiet --input-unix-socket=/tmp/imagesocket --loop-file"
export VIDPLAY="mpv --really-quiet --input-unix-socket=/tmp/mpvsocket"
export BROWSER="/usr/bin/google-chrome"

# applications
alias i="$IMGVIEW"
alias mpvt="$VIDPLAY"
alias mpvi="$VIDPLAY --idle &!"
alias chrome="dtach -A /tmp/chrome -z $BROWSER"

hash nvim 2> /dev/null && {
    export VISUAL="nvim"
    export EDITOR="nvim"
} || {
    hash vim 2> /dev/null && {
        export VISUAL="vim"
        export EDITOR="vim"
    } || {
        export VISUAL="vi"
        export EDITOR="vi"
    }
}

export PAGER="less"
export MANPAGER="$PAGER"

alias vi="$VISUAL"
alias vim="$VISUAL"
alias emacs="emacs -nw"

alias width="cut -c1-$(stty size </dev/tty | cut -d\  -f 2)"
alias nocolor="sed 's/\x1B\[[0-9;]*[JKmsu]//g'"

alias more="nocolor | $VISUAL -"
alias lesscolor="nocolor | $PAGER"

test -f ~/.ssh/iouprc && export IOUP_TOKEN="$(< ~/.ssh/iouprc)"
