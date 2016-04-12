type crux 2>&1 > /dev/null && {
    export PORTS="/usr/ports"
    export SOURCES="$(grep "PKGMK_SOURCE_DIR" /etc/pkgmk.conf | cut -d'"' -f 2)"

    alias prtrem="s prt-get remove"
    alias prtlock="s prt-get lock"
    alias prtinst="s prt-get install"
    alias prtinsd="s prt-get depinst"
    alias prtunlock="s prt-get unlock"
    alias prtupdate="s prt-get update"

    alias prtls="prt-get ls"
    alias prtedit="prt-get edit"
    alias prtpath="prt-get path"
    alias prtinfo="prt-get info"
    alias prtdiff="prt-get diff"
    alias prtread="prt-get readme"
    alias prtsrch="prt-get dsearch"
    alias prtlist="prt-get listinst"
    alias prtorph="prt-get listorphans"
    alias prtcache="prt-get cache"
    alias prtfsrch="prt-get fsearch"
    alias prtcount="prt-get listinst | wc -l"
    alias prtlocked="prt-get listlocked"

    prtgo() {
        prt-get path "$@" && cd $(prtpath "$@")
    }

    prtcp() {
        test $(prt-get search "$1" | wc -l) -eq 1 && {
            USRPORTS="$PORTS/wildefyr"
            PORTPATH="$(prt-get info "$1" | awk '/Path:/ {print $2}')"

            test ! -d "$USRPORTS/$1" && {
                cp "$PORTPATH/$1" "$USRPORTS/wildefyr"
                prt-get cache
                prt-get edit "$1"
            }

            unset -v USRPORTS PORTPATH
        } || {
            printf '%s\n' "Search term gives too many results."
            return 1
        }
    }

    prtcat() {
        test -z $1 && {
            printf '%s\n' "Usage: prtcat [pkgname] <file>"
            return 1
        }

        package="$1"

        prt-get path "$package" > /dev/null && {
            packagePath=$(prt-get path "$package")
        } || {
            return 1
        }

        test -z "$2" && {
            test -f "${packagePath}/Pkgfile" && {
                vimcat "${packagePath}/Pkgfile"
            } || {
                printf '%s\n' "Pkgfile does not exist!"
                return 1
            }
        } || {
            shift
            for file in "$@"; do
                test -f "${packagePath}/${file}" && {
                    vimcat "${packagePath}/${file}"
                } || {
                    continue
                }
            done
        }

        unset -v package
    }

    prtdep() {
        test -z "$@" && {
            printf '%s\n' "Usage: prtdep [pkgname]"
            return 1
        }

        prt-get info "$@"

        deptree="$(prt-get deptree "$@" | sed '1d')"
        test ! -z "$deptree" && {
            printf '\n%s\n' "Package dependency tree:"
            prt-get deptree "$@" | sed '1d'
        } || {
            printf '\n%s' "$@ does not have any dependencies!"
        }

        dependent="$(prt-get dependent "$@")"
        test ! -z "$dependent" && {
            printf '\n%s\n' "Packages dependent:"
            printf '%s\n' "$dependent"
        } || {
            printf '\n%s\n' "$@ has no packages dependent on it!"
        }

        unset -v deptree dependent
    }

    prtdup() {
        test -z "$@" && {
            printf '%s\n' "Usage: prtdup [pkgname]"
            return 1
        }

        find $PORTS -type d -iname "*$@*" | cut -d'/' -f 4-
    }

    # cd into git cloned directories
    prtclone() {
        test -z "$@" && {
            printf '%s\n' "Usage: prtclone [pkgname]"
            return 1
        }

        prt-get cat $1 | grep -q "version=git" && {
            test ! -d $SOURCES/$1 && {
                prt-get isinst $1 && {
                    prt-get update -fr $1
                } || {
                    prt-get install -fr $1
                }
            }

            cd $SOURCES/$1
        }
    }

    prtupgrade() {
        s ports -u || return 1

        prt-get diff

        test ! -z "$(prt-get quickdiff)" && {
            printf '\n%s' "Upgrade Now? [Y/n]: "; while read -r confirm; do
                confirm=$(printf '%s\n' "$confirm" | tr '[A-Z]' '[a-z]')
                test "$confirm" = "n" && return 0 || break
                unset -v confirm
            done
        }

        # set permissions to current user
        chown $(echo $USER):users -R $PORTS/* || return 1

        # upgrade packages marked
        s prt-get sysup || return 1
    }

    prtrebuild() {
        prtupdate $(prt-get quickdep "$1")
    }

    rebuildcore() {
        cd $PORTS/core
        ls -1 | while read -r port; do
            port=$(printf '%s\n' "$port" | rev | cut -d'/' -f 2 | rev)
            prtupdate -fr $port
        done

        unset -v port
    }

    fuckthisfuckthatfuckeverything() {
        sudo prt-get update $(prt-get listinst) -fr
    }

    buildkernal() {
        test -d "./arch" && {
            make
            modinstall
            instkern
        }
    }
}
