# ~/.zshrc      interactive
setopt extended_glob
fpath=(/opt/homebrew/share/zsh/site-functions ~/.zsh/functions ~/.zsh/completions $fpath)
for fn in ~/.zsh/functions/*(N:t); autoload -Uz $fn
HISTFILE=~/.zsh_history; HISTSIZE=10000; SAVEHIST=10000
autoload -Uz compinit
# trust a dump younger than a day, else rebuild (glob runs outside [[ ]])
zcd=(~/.zcompdump(#qN.mh-24)); if (( $#zcd )); then compinit -C; else compinit -i; fi
for f in ~/.zsh/*.zsh~*/local.zsh(N) ~/.zsh/local.zsh(N); source $f
