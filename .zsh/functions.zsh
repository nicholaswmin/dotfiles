# functions.zsh
# custom shell functions

PS_LABEL="tunnel"

# always search hidden files unless told otherwise
fd() {
  local a
  for a in "$@"; do
    [[ $a == -H || $a == --hidden ]] && { command fd "$@"; return }
  done
  command fd -H "$@"
}

# quit every foreground app except comma-separated keep list
fresh() {
  local -a keep
  local p
  for p in ${(s:,:)1}; do
    p=${p//[[:space:]]/}
    [[ -n $p ]] && keep+=(${p:l})
  done

  local app al pat
  local apps=$(osascript -e 'tell application "System Events" to get name of (processes where background only is false)')
  for app in ${(s:, :)apps}; do
    [[ -z $app ]] && continue
    al=${app:l}
    for pat in $keep; do
      [[ $al == *$pat* ]] && continue 2
    done
    osascript -e "tell application \"${app//\"/\\\"}\" to quit" 2>/dev/null &
  done
  wait
}

# filesystem create/modify changes in the last N hours (default 24, 50 rows)
lc() {
  local h=${1:-24} n=${2:-50}
  [[ $h == <1-> ]] || h=24
  [[ $n == <1-> ]] || n=50

  local g='' y='' r=''
  [[ -t 1 && -z ${NO_COLOR-} ]] && { g=$'\e[1;32m'; y=$'\e[1;33m'; r=$'\e[0m' }

  local dt=${commands[gdate]:-${commands[date]}}
  local s=${commands[gstat]:-${commands[stat]}}
  local -i now cut
  now=$("$dt" +%s) || return 1
  cut=$(( now - h * 3600 ))

  local flag fmt
  if "$s" --version >/dev/null 2>&1; then
    flag=-c fmt=$'%W\t%Y\t%n'
  else
    flag=-f fmt=$'%B\t%m\t%N'
  fi

  find . -name .git -prune -o -name node_modules -prune -o \
    -type f -exec "$s" "$flag" "$fmt" {} + 2>/dev/null |
    awk -F'\t' -v cut="$cut" '
      { b=$1+0; m=$2+0; f=$3
        if (b<=0) b=-1
        if (b>=cut) { print b "\tA\t" f; next }
        if (m>=cut) { print m "\tM\t" f } }' |
    sort -nr | head -n "$n" |
    while IFS=$'\t' read -r ts st file; do
      local -i age=$(( (now - ts) / 3600 ))
      (( age < 0 )) && age=0
      local c=$y
      [[ $st == A ]] && c=$g
      printf '%b%s%b  %3dh ago  %s\n' "$c" "$st" "$r" "$age" "$file"
    done
}

# make files immutable (uchg)
lock() {
  (( $# )) || { print -u2 "usage: lock <file> ..."; return 1 }
  local f
  for f in "$@"; do
    [[ -e $f ]] || { print -u2 "$f not found"; continue }
    if /usr/bin/stat -f "%Sf" "$f" 2>/dev/null | grep -q uchg; then
      print "${f:a} already locked"
    elif chflags -R uchg "$f"; then
      print "${f:a} locked"
    fi
  done
}

# clear the immutable flag
unlock() {
  (( $# )) || { print -u2 "usage: unlock <file> ..."; return 1 }
  local f
  for f in "$@"; do
    [[ -e $f ]] || { print -u2 "$f not found"; continue }
    if /usr/bin/stat -f "%Sf" "$f" 2>/dev/null | grep -q uchg; then
      chflags -R nouchg "$f" && print "${f:a} unlocked"
    else
      print "${f:a} already unlocked"
    fi
  done
}

# route deletions through the trash
rm() {
  local -a files=(${@:#-*})
  (( $#files )) || { print -u2 "usage: rm <file> ..."; return 1 }
  command trash "${files[@]}"
}

# shpotify wrapper: no args -> help, one arg -> play
spotify() {
  (( $# )) || { command spotify --help; return }
  (( $# == 1 )) && { command spotify play "$1"; return }
  command spotify "$@"
}

# expose a local directory or proxy a url over cloudflare
tunnel() {
  command -v cloudflared &>/dev/null || {
    print -u2 "cloudflared not installed; brew install cloudflared"
    return 1
  }

  local named=""
  if [[ ${1-} == -d ]]; then
    named=${2-}
    [[ -n $named ]] || { print -u2 "-d requires a tunnel name"; return 1 }
    shift 2
  fi

  local target=${1:-.} dir url
  if [[ -d $target ]]; then
    dir=${target:A}
  elif [[ -e $target ]]; then
    print -u2 "path must be a directory: $target"
    return 1
  else
    [[ -n $named ]] && { print -u2 "-d requires a directory path"; return 1 }
    url=$target
    [[ $url != *://* ]] && url="http://$url"
    command cloudflared tunnel --label "$PS_LABEL" --url "$url"
    return
  fi

  local port=8473 server_pid=""
  trap '[[ -n $server_pid ]] && kill $server_pid 2>/dev/null; trap - INT TERM EXIT' INT TERM EXIT
  python3 -m http.server "$port" -d "$dir" &>/dev/null &
  server_pid=$!
  sleep 0.3
  kill -0 "$server_pid" 2>/dev/null || { print -u2 "file server failed on :$port"; return 1 }

  if [[ -n $named ]]; then
    command cloudflared tunnel --label "$PS_LABEL" run --url "http://localhost:$port" "$named"
  else
    command cloudflared tunnel --label "$PS_LABEL" --url "http://localhost:$port"
  fi
  local ret=$?
  kill "$server_pid" 2>/dev/null
  trap - INT TERM EXIT
  return "$ret"
}
