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
    npmins="s npm install -g"
}

# fuck pip seriously
type pip 2>&1 > /dev/null && {
    type crux 2>&1 > /dev/null && alias pip="pip --cert /etc/ssl/cert.pem"
    alias pipins="s pip install"
    alias piprem="s pip uninstall"
    alias pipupdate="s pip install --upgrade"
    alias pipinfo="pip show"
    alias piplist="pip list"
    alias pipsrch="pip search"

    pipupgrade() {
        pip list | while read -r line; do
            package=$(printf '%s\n' "$line" | cut -d\  -f 1)
            s pip install --upgrade $package
        done

        unset $package
    }

}

# ruby
type ruby 2>&1 > /dev/null && {
    alias gemins="s gem install"
    alias gemrem="s gem uninstall"
    alias gemupgrade="s gem update"
    alias gemlist="gem list"
    alias gemclean="s gem cleanup"
}

# fzf
type fzf 2>&1 > /dev/null && {
    . "$HOME/.fzf/shell/completion.zsh"
    . "$HOME/.fzf/shell/key-bindings.zsh"
}

# manual
type make 2>&1 > /dev/null && {
    alias makefile="$EDITOR Makefile"
    alias menuconfig="make menuconfig"
    alias modinstall="s make modules_install"
}
