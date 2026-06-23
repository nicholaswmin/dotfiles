# ~/.zprofile   login; after /etc/zprofile's path_helper, so PATH + brew belong here
eval "$(/opt/homebrew/bin/brew shellenv)"
path=(
  ~/.local/bin
  /opt/homebrew/opt/coreutils/libexec/gnubin   # GNU coreutils from the Brewfile
  /opt/homebrew/opt/postgresql@18/bin          # keg-only formula from the Brewfile
  $path
)
