# tools.zsh
# development tool integrations

# node version manager
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# kubectl completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi

# heroku autocomplete
HEROKU_AC_ZSH_SETUP_PATH="$HOME/Library/Caches/heroku/autocomplete/zsh_setup"
if [[ -f "$HEROKU_AC_ZSH_SETUP_PATH" ]]; then
  source "$HEROKU_AC_ZSH_SETUP_PATH"
fi
