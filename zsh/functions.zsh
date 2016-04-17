chpwd() {
    clear

    f0='[30m'; f1='[31m'; f2='[32m'; f3='[33m'
    f4='[34m'; f5='[35m'; f6='[36m'; f7='[37m'
    R='[0m'

    test $(ls -1 | wc -l) -gt 100 && {
        files=$(find -maxdepth 1 -type f | wc -l)
        links=$(find -maxdepth 1 -type l | wc -l)
        dirts=$(find -maxdepth 1 -type d | sed '1d' | wc -l)

        printf '%s\n\n' "$f3$files files ${R}&& $f6$dirts directories ${R}&& $f5$links links${R}"
        return 0
    }

    test -z "$(ls -1)" && {
        printf '%s\n\n' "${f5}Directory is empty!${R}"
    } || {
        ls --color=auto -F -N
        printf '\n'
    }

    # set window title to path name
    print -Pn "\e]0;%~\a"

    unset -v f0 41 f2 f3 f4 f5 f6 f7 R
}

zshrc() {
    RWD=$PWD

    cd ~/.zsh
    $EDITOR *

    . ~/.zshrc

    test "$PWD" != "$RWD" && cd $RWD

    unset -v RWD
}

vimrc() {
    $EDITOR ~/.vim/vimrc
}

:h() {
    test ! -z "$1" && {
        $EDITOR +"help $1" +only +'map q ZQ'
    }
}

updatedots() {
    RWD=$PWD
    cd $DOTS
    git pull --rebase && {szsh; cd $RWD; }
}

mem() {
    type ccze 2>&1 > /dev/null && {
        free -ht | ccze -A
    } || {
        free -ht
    }
}

dlog() {
    type ccze 2>&1 > /dev/null && {
        dmesg | tail -n 30 | ccze -A
    } || {
        dmesg | tail -n 30
    }
}

disks() {
    type ccze 2>&1 > /dev/null && {
        df -h | grep "/dev/" | sort -h | ccze -A
    } || {
        df -h | grep "/dev/" | sort -h
    }
}

psusr() {
    type ccze 2>&1 > /dev/null && {
        ps xgf "$@" | sed '1d; s/--type.*//' | ccze -A
    } || {
        ps xgf "$@" | sed '1d; s/--type.*//'
    }
}

# pasting
out() {
    PASTE="/tmp/paste"
    test -f "$PASTE" && cat "$PASTE"
    unset -v PASTE
}

alias xsel="xsel -l /dev/null"

iopaste() {
    test ! -z $DISPLAY && {
        curl -sLT- https://p.iotek.org | xsel -i
        xsel -o | xsel -ib
    } || {
        curl -sLT- https://p.iotek.org
    }
}

ixpaste() {
    test ! -z $DISPLAY && {
        curl -sF "f:1=<-" ix.io | xsel -i
        xsel -o | xsel -ib
    } || {
        curl -sF "f:1=<-" ix.io
    }
}

# music
alias shuffle="find $MUS -type f | sort -R | mpvc & 2>&1 > /dev/null"

mps() {
    mpsyt userpl wildefyri "$@"
}

music() {
    find $MUS -type f -iname "*$@*" | mpvc 2>&1 > /dev/null
}

# find shortcuts
findexec() {
    find . -maxdepth 1 -type f -executable | sort
}

editexec() {
    $EDITOR $(findexec) "$@"
}

findfile() {
    case "$1" in
        "-a")
            type ccze 2>&1 > /dev/null && {
                files=$(find . -maxdepth 1 | sed '1d' | grep -v "\./\.git" | sort -k2)
                printf '%s\n' "$files" | while read -r file; do
                    file "$file" | ccze -A
                done
            } || {
                files=$(find . -maxdepth 1 | sed '1d' | grep -v "\./\.git" | sort -k2)
                printf '%s\n' "$files" | while read -r file; do
                    file "$file"
                done
            }
            ;;
        *)
            type ccze 2>&1 > /dev/null && {
                files=$(find . -maxdepth 1 | sed '1d' | grep -v "\./\." | sort -k2)
                printf '%s\n' "$files" | while read -r file; do
                    file "$file" | ccze -A
                done
            } || {
                files=$(find . -maxdepth 1 | sed '1d' | grep -v "\./\." | sort -k2)
                printf '%s\n' "$files" | while read -r file; do
                    file "$file"
                done
            }
            ;;
    esac
}

# misc
pdf() {
    mupdf "$@" &!
}
