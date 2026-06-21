# environment.zsh
# interactive environment variables (EDITOR + XDG live in .zshenv)

export HOMEBREW_NO_ENV_HINTS=1
export PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"

# ls/tree colors
export LS_COLORS='di=38;5;111:ln=38;5;73:ex=38;5;108:fi=0:*.js=38;5;183:*.ts=38;5;183:*.jsx=38;5;183:*.tsx=38;5;183:*.html=38;5;216:*.css=38;5;117:*.scss=38;5;117:*.json=38;5;187:*.md=38;5;223:*.log=90:or=31'
export LSCOLORS='ExGxFxdxCxDxDxhbadExEx'

# let CLIs use their default config locations
unset AWS_CONFIG_FILE
unset AWS_SHARED_CREDENTIALS_FILE
unset DOCKER_CONFIG
unset KUBECONFIG

# ssh security-key provider
export SSH_SK_PROVIDER=/usr/lib/ssh-keychain.dylib
