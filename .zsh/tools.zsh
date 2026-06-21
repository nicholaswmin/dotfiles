# tools.zsh
# development tool integrations

# node version manager
command -v fnm >/dev/null 2>&1 && eval "$(fnm env --use-on-cd)"

# kubectl completion
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)

# heroku autocomplete
HEROKU_AC_ZSH_SETUP_PATH="$HOME/Library/Caches/heroku/autocomplete/zsh_setup"
[[ -f "$HEROKU_AC_ZSH_SETUP_PATH" ]] && source "$HEROKU_AC_ZSH_SETUP_PATH"
