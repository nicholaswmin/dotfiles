# ~/.zshrc      interactive
setopt EXTENDED_GLOB   # needed before the module-sourcing exclusion glob below
fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
autoload -Uz compinit
# trust a dump younger than a day, else rebuild; the glob runs outside [[ ]]
zcd=(~/.zcompdump(#qN.mh-24)); if (( $#zcd )); then compinit -C; else compinit -i; fi
for f in ~/.zsh/*.zsh~*/local.zsh(N) ~/.zsh/local.zsh(N); source $f
