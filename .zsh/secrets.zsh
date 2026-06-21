# load_secret VAR service - export VAR from the `environment` keychain; fail loud
load_secret() {
  local v
  v=$(security find-generic-password -s "$2" -w environment) || {
    print -u2 "load_secret: '$2' not in the environment keychain"; return 1
  }
  export "$1=$v"
}
# secret service - print a secret on demand; nothing lingers in the environment
secret() {
  security find-generic-password -s "$1" -w environment || {
    print -u2 "secret: '$1' not in the environment keychain"; return 1
  }
}
