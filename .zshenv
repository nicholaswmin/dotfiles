# ~/.zshenv     read first; universal env only, NOT PATH, since path_helper reorders it
typeset -U path PATH
export XDG_CONFIG_HOME=$HOME/.config XDG_DATA_HOME=$HOME/.local/share XDG_CACHE_HOME=$HOME/.cache
export EDITOR='/opt/homebrew/bin/zed --wait' VISUAL='/opt/homebrew/bin/zed --wait'   # absolute: resolvable in non-login shells
