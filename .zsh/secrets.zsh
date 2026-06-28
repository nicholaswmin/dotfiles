# load_secret VAR service - export VAR from the `.env` keychain; fail loud
load_secret() {
  emulate -L zsh
  local v
  v=$(security find-generic-password -s "$2" -w "$HOME/Library/Keychains/.env.keychain-db") || {
    print -u2 "load_secret: '$2' not in the .env keychain"; return 1
  }
  export "$1=$v"
}
# secret service - print a secret on demand; nothing lingers in the environment
secret() {
  emulate -L zsh
  security find-generic-password -s "$1" -w "$HOME/Library/Keychains/.env.keychain-db" || {
    print -u2 "secret: '$1' not in the .env keychain"; return 1
  }
}
