# turn autocompletion on
autoload -z compinit
compinit

# custom completions
fpath=($fpath $HOME/.zsh/completions)

zstyle ':completion:*' menu select=2 eval "$(dircolors -b)"
