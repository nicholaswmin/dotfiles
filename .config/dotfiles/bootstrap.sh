#!/usr/bin/env sh
# bootstrap - restore nicholaswmin/dotfiles onto a fresh macOS box

set -eu

# source
# ---
REPO="${DOTFILES_REPO:-https://github.com/nicholaswmin/dotfiles}"
REF="${DOTFILES_REF:-main}"

# logging
# ---
LOG="${TMPDIR:-/tmp}/dotfiles-bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec 3>&2
exec >>"$LOG" 2>&1

_grn='' _red='' _rst=''
if [ -z "${NO_COLOR+x}" ] &&
   { [ "${CLICOLOR_FORCE:-0}" != 0 ] || { [ "${CLICOLOR:-1}" != 0 ] && [ -t 3 ]; }; }
then
  _grn=$(printf '\033[1;32m') _red=$(printf '\033[1;31m') _rst=$(printf '\033[0m')
fi

say() { printf '==> %s\n' "$*"; printf '%s %s\n' "${_grn}==>${_rst}"   "$*" >&3; }
die() { printf 'error: %s\n' "$*"; printf '%s %s\n' "${_red}error:${_rst}" "$*" >&3; exit 1; }

# git
# ---
command -v git >/dev/null 2>&1 || die "git missing - run 'xcode-select --install' first"

# homebrew
# ---
if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ]; then
  say "installing Homebrew"
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
command -v brew >/dev/null 2>&1 || die "Homebrew not on PATH after install - see $LOG"

# checkout into $HOME
# ---
cd "$HOME"
[ -d .git ] || { say "git init in \$HOME"; git init -q; }
[ "$(git rev-parse --show-toplevel)" = "$HOME" ] || die "worktree root is not \$HOME"

url=$(git config --get remote.origin.url 2>/dev/null || true)
[ -n "$url" ] || { git remote add origin "$REPO"; url="$REPO"; }
[ "$url" = "$REPO" ] || die "origin is '$url', expected '$REPO'"

say "fetching $REPO ($REF)"
git fetch -q origin "$REF"
say "checkout -f (overwrites colliding stock files)"
git checkout -f -B main FETCH_HEAD
rm -f "$HOME/.gitconfig"

# provision
# ---
say "brew bundle"
brew bundle --file "$HOME/.config/dotfiles/Brewfile" || _bundle_failed=1
say "macos defaults"
zsh "$HOME/.config/dotfiles/macos.zsh" || _macos_failed=1
if [ "${_bundle_failed:-0}" = 1 ]; then die "brew bundle had failures - see $LOG"; fi
if [ "${_macos_failed:-0}" = 1 ]; then die "macos defaults had failures - see $LOG"; fi

# node
# ---
say "node"
fnm install 26
fnm default 26

# done
# ---
say "done - restart your shell:  exec zsh -l"
