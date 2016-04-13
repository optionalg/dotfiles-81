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
    alias prtcur="prt-get list"
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

        type vimcat 2>&1 > /dev/null && {
            CATCMD="vimcat"
        } || {
            CATCMD="cat"
        }

        test -z "$2" && {
            test -f "${packagePath}/Pkgfile" && {
                $CATCMD "${packagePath}/Pkgfile"
            } || {
                printf '%s\n' "Pkgfile does not exist!"
                return 1
            }
        } || {
            shift
            for file in "$@"; do
                test -f "${packagePath}/${file}" && {
                    $CATCMD "${packagePath}/${file}"
                } || {
                    continue
                }
            done
        }

        unset -v CATCMD package
    }

    prtdeps() {
        test -z "$@" && {
            printf '%s\n' "Usage: prtdep [pkgname]"
            return 1
        }

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

    prtduplicated() {
        test -z "$@" && {
            printf '%s\n' "Usage: prtduplicated [pkgname]"
            return 1
        }

        duplicated=$(find $PORTS -mindepth 2 -maxdepth 2 -type d -iname "$@" | \
            cut -d'/' -f 4- | grep -v "\.git" | grep -v "^$" | sort)

        test ! -z $duplicated && {
            test $(printf '%s\n' "$duplicated" | wc -l) -ne 1 && {
                printf '%s\n' "$duplicated"
            } || {
                return 2
            }
        } || {
            return 1
        }
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

    prtrebuild() {
        prt-get update $(prt-get quickdep "$1")
    }

    prtrepobuild() {
        test -z "$@" && {
            printf '%s\n' "Usage: prtrepobuild [repo name]"
            return 1
        }

        "$portdirectory"=$(find $PORTS -maxdepth 1 -type d -name "$@")

        test ! -z "$portdirectory" && {
            cd "$portdirectory"
            find -type d -exec prt-get update -fr {} \;
        } || {
            return 2
        }
    }

    prtupgrade() {
        s ports -u || return 1

        printf '\n'
        prt-get diff
        printf '\n%s\n' "The following packages are currently locked:"
        prt-get listlocked
        printf '\n'

        test ! -z "$(prt-get quickdiff)" && {
            printf '\n%s' "Upgrade Now? [Y/n]: "; while read -r confirm; do
                confirm=$(printf '%s\n' "$confirm" | tr '[A-Z]' '[a-z]')
                test "$confirm" = "n" && return 0 || break
                unset -v confirm
            done
        } || {
            return 2
        }

        printf '\n'

        # set permissions to current user
        ME=$(echo $USER)
        s chown ${ME}:users -R $PORTS/* || return 1

        # upgrade packages marked
        s prt-get sysup || return 1

        unset -v ME
    }
}
