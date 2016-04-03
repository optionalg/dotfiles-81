type git 2>&1 > /dev/null && {

    # general
    alias ga="git add"
    alias gb="git branch"
    alias gr="git remote"
    alias gs="git status -sb"
    alias gco="git commit -m"
    alias gck="git checkout"
    alias gpl="git pull"
    alias gplr="git pull --rebase"
    alias gpop="git stash pop"

    gc() {
        git clone "$@" || return 1

        test -z "$2" && {
            CLONED="$(printf '%s\n' "$@" | rev | cut -d'/' -f 1 | rev)"
        } || {
            CLONED="$2"
        }

        test -d "$PWD/$CLONED" && cd "$PWD/$CLONED"

        test -d "./.hooks" && {
            printf '%s' "Deploy hooks? [Y/n]: "; while read -r confirm; do
                confirm=$(printf '%s\n' "$confirm" | tr '[A-Z]' '[a-z]')
                test "$confirm" = "n" && break || {deployhooks; break;}
            done
        }

        unset -v CLONED
    }

    # diffs and shit
    gd() {
        type cliff 2>&1 > /dev/null && {
            git diff "$@" | cat - | cliff
        } || {
            git diff "$@"
        }
    }

    ggrep() {
        type ccze 2>&1 > /dev/null && {
            git grep "$@" | tac - | ccze -A
        } || {
            git grep "$@" | tac -
        }
    }

    # staging and pushing
    unstage() {
        git reset --soft HEAD~
        reset HEAD --
    }

    gph() {
        git rev-parse --is-inside-git-dir 2>&1 > /dev/null && {
            printf '\n%s\n\n' "$(wild)"
            git push "$@" && {
                POSTPUSH="$(git rev-parse --show-toplevel)/.git/hooks/post-push"
                test -f "$POSTPUSH" 2>&1 > /dev/null && $POSTPUSH
            }
        }

        unset -v POSTPUSH
    }

    # stashes
    stashed() {
        type ccze 2>&1 > /dev/null && {
            git stashed "$@" | tac - | ccze -A
        } || {
            git stashed "$@" | tac -
        }
    }

    prevstash() {
        type ccze 2>&1 > /dev/null && {
            git stash show | cat - | ccze -A
        } || {
            git stash show | cat -
        }
    }

    # history
    gg() {
        type ccze 2>&1 > /dev/null && {
            git graph "$@" | tac - | sed 's_/_|_g; s_\\_|_g' | ccze -A
        } || {
            git graph "$@" | tac - | sed 's_/_|_g; s_\\_|_g'
        }
    }

    gl() {
        type ccze 2>&1 > /dev/null && {
            git log "$@" --stat | tac - | ccze -A
        } || {
            git log "$@" --stat | tac -
        }
    }

    gsl() {
        type ccze 2>&1 > /dev/null && {
            git shortlog "$@" | cat - | ccze -A
        } || {
            git shortlog "$@" | cat -
        }
    }

    # remotes
    setorigin() {
        test -z "$(git remote)" && {
            git remote add origin "$@"
        } || {
            get remote set-url origin "$@"
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
