type crux 2>&1 > /dev/null && {
    export PORTS="/usr/ports"
    export SOURCES="$(grep "PKGMK_SOURCE_DIR" /etc/pkgmk.conf | cut -d'"' -f 2)"

    alias portsync="s ports -u"

    portlist() {
        ports -l | cut -d'/' -f 1 | uniq | while read -r REPO; do
            find /etc/ports/ -maxdepth 1 -type f -name "*$REPO*" | \
            grep -q "inactive" && {
                printf '%s  %s\n' "inactive" "$REPO"
            } || {
                printf '%s    %s\n' "active" "$REPO"
            }
        done
    }

    portoggle() {
        test $# -eq 0 && {
            printf '%s\n' "Usage: portoggle [repository]"
            return 1
        }

        portlist=$(portlist)

        printf '%s\n' "$portlist" | grep -q "$@" && {
            sync=$(find /etc/ports -maxdepth 1 -type f -name "*$@*" | \
                   cut -d'/' -f 4 | cut -d'.' -f 2)

            printf '%s\n' "$portlist" | grep -q "active" && {
                sudo mv /etc/ports/"$@"."$sync".inactive /etc/ports/"$@"."$sync" 2> /dev/null
            } || {
                sudo mv /etc/ports/"$@"."$sync"* /etc/ports/"$@"."$sync".inactive
            }

            portlist
            unset -v sync
        } || {
            printf '%s\n' "Port repository does not exist."
            return 1
        }
    }

    alias prtrem="s prt-get remove"
    alias prtlock="s prt-get lock"
    alias prtinst="s prt-get install"
    alias prtinsd="s prt-get depinst"
    alias prtunlock="s prt-get unlock"

    alias prtls="prt-get ls"
    alias prtcur="prt-get list"
    alias prtpath="prt-get path"
    alias prtdiff="prt-get diff"
    alias prtread="prt-get readme"
    alias prtsrch="prt-get dsearch"
    alias prtlist="prt-get listinst"
    alias prtorph="prt-get listorphans"
    alias prtdups="prt-get dup"
    alias prtcache="prt-get cache"
    alias prtfsrch="prt-get fsearch"
    alias prtcount="prt-get listinst | wc -l"
    alias prtisinst="prt-get isinst"
    alias prtlocked="prt-get listlocked"

    prtcat() {
        test -z $1 && {
            printf '%s\n' "Usage: prtcat [package] <file>"
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
                printf '%s\n' "Pkgfile does not exist."
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

    prtinfo() {
        prt-get info "$@"
        printf '\n'
        prt-get isinst "$@"
    }

    prtedit() {
        prt-get edit "$@"
        prtverify $(prt-get path "$1")
    }

    prtdeps() {
        test -z "$@" && {
            printf '%s\n' "Usage: prtdeps [package]"
            return 1
        }

        prt-get info "$@" 2>&1 > /dev/null || return 1

        deptree="$(prt-get deptree "$@" | sed '1d')"
        test ! -z "$deptree" && {
            printf '%s\n' "Package dependency tree:"
            prt-get deptree "$@" | sed '1d'
        } || {
            printf '%s\n' "$@ does not have any dependencies."
        }

        dependents="$(prt-get dependent "$@")"
        test ! -z "$dependents" && {
            printf '\n%s\n' "Packages dependinging on ${@}:"
            printf '%s\n' "$dependents"
        } || {
            printf '\n%s\n' "$@ has no packages dependent on it."
        }

        unset -v deptree dependent
    }

    prtdup() {
        duplicated=$(find $PORTS -mindepth 2 -maxdepth 2 -type d -iname "$@" | \
                     cut -d'/' -f 4- | grep -v "\.git\|^$" | sort)

        test ! -z "$duplicated" && {
            test $(printf '%s\n' "$duplicated" | wc -l) -ne 1 && {
                printf '%s\n' "$duplicated"
            } || {
                return 2
            }
        } || {
            printf '%s\n' "Package '$@' not found"
            return 1
        }
    }

    prtfile() {
        prt-get path "$@" && cd $(prtpath "$@")
    }

    # cd into a source directory if it exists
    prtgo() {
        test -z "$@" && {
            printf '%s\n' "Usage: prtsource [package]"
            return 1
        }

        prt-get cat "$1" | grep -q "version=git" && {
            test ! -d "$SOURCES/$1" && {
                prt-get isinst "$1" || {
                    sudo prt-get depinst -fr "$1"
                }
            }

            cd "$SOURCES/$1"
        } || {
            printf '%s\n' "$1 is not a git package."
        }
    }

    prtrebuild() {
        sudo prt-get update -fr $(prt-get quickdep "$@")
    }

    prtupdate() {
        sudo prt-get update "$@"
    }

    prtupgrade() {
        sudo ports -u || return 1

        printf '\n'
        prt-get diff

        locked=$(prt-get listlocked)
        test "$locked" != "Failed to open lock data file" && {
            test ! -z "$locked" && {
                printf '\n%s' "The following packages are currently locked:"
                printf '\n%s\n\n' "$locked"
            }
        }

        test ! -z "$(prt-get quickdiff)" && {
            printf '\n%s' "Upgrade Now? [Y/n]: "; while read -r confirm; do
                confirm=$(printf '%s\n' "$confirm" | tr '[A-Z]' '[a-z]')
                test "$confirm" = "n" && return || break
                unset -v confirm
            done
        } || {
            return 2
        }

        printf '\n'

        # set permissions to current user
        ME=$(echo $USER)
        sudo chown ${ME}:users -R $PORTS/*

        # upgrade packages marked
        sudo prt-get sysup || return 1

        unset -v ME
    }
}

# alpine
type apk 2>&1 > /dev/null && {
    alias apkinfo="apk info"
    alias apksrch="apk search"

    alias apkins="s apk add"
    alias apkrem="s apk del"

    apkupg() {
        sudo apk update
        sudo apk upgrade
    }
}

# systemd distros
type hostnamectl 2>&1 > /dev/null && {
    OS=$(hostnamectl | grep "Operating System:")

    # debian / ubuntu
    printf '%s\n' "$OS" | grep -q "Debian\|Ubuntu" && {
        alias aptins="s apt-get install"
        alias aptrem="s apt-get remove"
        alias aptupdate="s apt-get update"
        alias aptupgrade="s apt-get upgrade"
        alias aptclean="s apt-get autoremove"
        alias aptsrch="apt-cache search"
        alias aptinfo="apt-cache showpkg"
    }

    # arch
    printf '%s\n' "$OS" | grep -q "Arch Linux" && {
        alias pacins="s pacman -S"
        alias pacrem="s pacman -Rs"
        alias pacupgrade="s pacman -Syu"
        alias paclist="pacman -Q"
        alias pacinfo="pacman -Qi"
        alias pacsrch="pacman -Ss"
        alias paccount="pacman -Q | wc -l"
        alias pacorphans="pacman -Qdt"
    }
}

# nodejs
type npm 2>&1 > /dev/null && {
    alias npmins="s npm install -g"
    alias npmupgrade="s npm update -g"

    alias npmown="npm owner ls"
    alias npmdiff="npm outdated -g"
    alias npmlist="npm list -g --depth=0"
    alias npmdirs="find $(npm root -g) -maxdepth 1 -type d | sed '1d' | rev | \
                   cut -d'/' -f 1 | rev"

    npmversion() {
        npm view "$@" version
    }
}

# python
type pip 2>&1 > /dev/null && {
    # prefer pip3 by default
    type pip3 2>&1 > /dev/null && {
        pipversion="pip3"
    } || {
        pipversion="pip2"
    }

    alias pipinfo="$pipversion show"
    alias piplist="$pipversion list"
    alias pipsrch="$pipversion search"

    alias pipins="s $pipversion install"
    alias piprem="s $pipversion uninstall"
    alias pipupdate="s $pipversion install --upgrade"

    pipupgrade() {
        $pipversion list | while read -r line; do
            package=$(printf '%s\n' "$line" | cut -d\  -f 1)
            s $pipversion install --upgrade $package
        done

        unset $package
    }
}

# ruby
type ruby 2>&1 > /dev/null && {
    alias gemins="s gem install"
    alias gemrem="s gem uninstall"
    alias gemclean="s gem cleanup"
    alias gemupgrade="s gem update"

    alias gemcur="gem list"
    alias gemlist="gem list --local"
}

# manual
type make 2>&1 > /dev/null && {
    alias makefile="$EDITOR Makefile"
    alias menuconfig="make menuconfig"
    alias modinstall="s make modules_install"

    buildkernel() {
        test -d "./arch" && {
            make && modinstall && instkern
        } || {
            printf '%s\n' "Not in a linux kernel directory."
            return 1
        }
    }
}

# fzf
type fzf 2>&1 > /dev/null && {
    . "$HOME/.fzf/shell/completion.zsh"
    . "$HOME/.fzf/shell/key-bindings.zsh"
}
