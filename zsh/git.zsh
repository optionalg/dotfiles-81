# shall we play a game

type git 2>&1 > /dev/null && {

    # fetching
################################################################################

alias gpl="git pull"
alias rebase="git pull --rebase"

gc() {
    git clone "$@" || return 1

    test -z "$2" && {
        CLONED="$(printf '%s\n' "$@" | rev | cut -d'/' -f 1 | rev)"
    } || {
        CLONED="$2"
    }

    test -d "$PWD/$CLONED" && cd "$PWD/$CLONED"

    test -d "./.hooks" && {
        printf '%s' "Deploy hooks? [Y/n]: "
        while read -r confirm; do
            confirm=$(printf '%s\n' "$confirm" | tr '[A-Z]' '[a-z]')
            test "$confirm" = "n" && break || {
                deployhooks
                break
            }
        done
    }

    unset -v CLONED
}

# diffs and shit
################################################################################

gd() {
    type cliff 2>&1 > /dev/null && {
        git diff "$@" | cat - | cliff
    } || {
        git diff "$@"
    }
}

ggrep() {
    git grep "$@" | sed "s_$@_\[35m$@\[0m_"
}

cgrep() {
    grep -r "$@" | grep -v "\.git" | sed "s_$@_\[35m$@\[0m_"
}

# staging
################################################################################

alias ga="git add"
alias gs="git status -sb"
alias amend="git commit --amend"
alias uncommit="git reset --mixed HEAD~"
alias unstage="git reset -q HEAD --"
alias discard="git checkout --"

alias nuclear="git reset --hard HEAD && git clean -d -f"

gco() {
    test -z "$@" && {
        git commit
    } || {
        git commit -m "$@"
    }
}

# pushing
################################################################################

gph() {
    git rev-parse --is-inside-git-dir 2>&1 > /dev/null && {
        printf '\n%s\n\n' "$(fyr)"
        git push "$@" && {
            POSTPUSH="$(git rev-parse --show-toplevel)/.git/hooks/post-push"
            test -f "$POSTPUSH" 2>&1 > /dev/null && $POSTPUSH
        }
    }

    unset -v POSTPUSH
}

# branches
################################################################################

alias gb="git branch"
alias gck="git checkout"

checkout() {
    git checkout $(git name-rev --name-only "$@")
}

# stashes
################################################################################

alias stash="git stash"
alias popstash="git stash pop"

stashed() {
    type ccze 2>&1 > /dev/null && {
        git stash list "$@" | tac - | ccze -A
    } || {
        git stash list "$@" | tac -
    }
}

prevstash() {
    type ccze 2>&1 > /dev/null && {
        git stash show | ccze -A
    } || {
        git stash show
    }
}

# history
################################################################################

alias gsl="git shortlog"

gg() {
    type ccze 2>&1 > /dev/null && {
        git graph "$@" | tac - | sed 's_/_|_g; s_\\_|_g' | ccze -A
    } || {
        git graph "$@" | tac - | sed 's_/_|_g; s_\\_|_g'
    }
}

gl() {
    type ccze 2>&1 > /dev/null && {
        git ls "$@" | tac - | sed 's_/_|_g; s_\\_|_g' | ccze -A
    } || {
        git ls "$@" | tac - | sed 's_/_|_g; s_\\_|_g'
    }
}

# remotes
################################################################################

alias gr="git remote"

setorigin() {
    test -z "$(git remote)" && {
        git remote add origin "$@"
    } || {
        git remote set-url origin "$@"
    }
}

addremote() {
    test -z "$(git remote)" && {
        git remote add origin "$1"
    } || {
        test $# -lt 2 && {
            printf '%s\n' "Specify remote name!"
            return 1
        }

        git remote add "$2" "$1"
    }
}

delremote() {
    test -z "$(git remote)" && {
        return 1
    } || {
        test ! -z "$@" && {
            git remote remove "$1"
        }
    }
}

# hooks
################################################################################

deployhooks() {
    git rev-parse --is-inside-git-dir 2>&1 > /dev/null && {
        TOPDIR="$(git rev-parse --show-toplevel)/.hooks"
        GITDIR="$(git rev-parse --git-dir)/hooks"

        test -d "$TOPDIR" && {
            rm -rf "$GITDIR"
            ln -sv "$TOPDIR" "$GITDIR"
        }

        unset -v TOPDIR GITDIR
    } || {
        printf '%s\n' "You're not inside a git directory!"
        return 1
    }
}

generatehooks() {
    git rev-parse --is-inside-git-dir 2>&1 > /dev/null && {
        TOPDIR="$(git rev-parse --show-toplevel)/.hooks"
        GITDIR="$(git rev-parse --git-dir)/hooks"

        test ! -d "$TOPDIR" && {
            rm -rf $GITDIR/*.samples
            cp -rf "$GITDIR" "$TOPDIR"
            rm -rf "$GITDIR"
            ln -sv "$TOPDIR" "$GITDIR"
            git add "$TOPDIR"
            git commit -m 'Add: custom git hooks'
        } || {
            printf '%s\n' "Custom hooks directory already exists!"
        }

        unset -v TOPDIR GITDIR
    } || {
        printf '%s\n' "You're not inside a git directory!"
        return 1
    }
}

}
