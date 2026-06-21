#!/usr/bin/env sh
# bootstrap - restore nicholaswmin/dotfiles onto a fresh macOS machine.
# POSIX sh; idempotent. After this it is plain git from $HOME, no manager.
# Override the source with DOTFILES_REPO / DOTFILES_REF (default: canonical, main).
set -eu

REPO="${DOTFILES_REPO:-https://github.com/nicholaswmin/dotfiles}"
REF="${DOTFILES_REF:-main}"

# --- logging: full transcript to a timestamped file; progress to the terminal --
# fd 3 stays the terminal (coloured ==> progress); stdout+stderr go to the log,
# so it captures brew/git output too. No pipe, so the exit status is preserved.
# Colour: NO_COLOR (off) > CLICOLOR_FORCE (on) > CLICOLOR + tty (tested on fd 3).
LOG="${TMPDIR:-/tmp}/dotfiles-bootstrap-$(date +%Y%m%d-%H%M%S).log"
exec 3>&2
exec >>"$LOG" 2>&1
if   [ -n "${NO_COLOR+x}" ];                 then _color=0
elif [ "${CLICOLOR_FORCE:-0}" != 0 ];        then _color=1
elif [ "${CLICOLOR:-1}" != 0 ] && [ -t 3 ];  then _color=1
else                                              _color=0
fi
if [ "$_color" = 1 ]; then
  _grn=$(printf '\033[1;32m'); _red=$(printf '\033[1;31m'); _rst=$(printf '\033[0m')
else
  _grn=''; _red=''; _rst=''
fi
say() { printf '==> %s\n' "$*"; printf '%s %s\n' "${_grn}==>${_rst}"   "$*" >&3; }
die() { printf 'error: %s\n' "$*"; printf '%s %s\n' "${_red}error:${_rst}" "$*" >&3; exit 1; }

# 1 - git (ships with the Xcode Command Line Tools)
command -v git >/dev/null 2>&1 || die "git missing - run 'xcode-select --install' first"

# 2 - Homebrew
if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ]; then
  say "installing Homebrew"
  sudo -v   # cache sudo creds: NONINTERACTIVE suppresses Homebrew's own sudo prompt, which
            # otherwise aborts on a password-protected admin (no-op under passwordless sudo)
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3 - check the repo out into $HOME (non-bare: .git lives in $HOME)
cd "$HOME"
[ -d .git ] || { say "git init in \$HOME"; git init -q; }
[ "$(git rev-parse --show-toplevel)" = "$HOME" ] || die "worktree root is not \$HOME"
# validate the RAW origin (get-url would expand insteadOf/pushInsteadOf)
url=$(git config --get remote.origin.url 2>/dev/null || true)
[ -n "$url" ] || { git remote add origin "$REPO"; url="$REPO"; }
[ "$url" = "$REPO" ] || die "origin is '$url', expected '$REPO'"
say "fetching $REPO ($REF)"
git fetch -q origin "$REF"
say "checkout -f (overwrites colliding stock files)"
git checkout -f -B main FETCH_HEAD
# the tracked XDG config is the only git config; drop a stray ~/.gitconfig that would override it
rm -f "$HOME/.gitconfig"

# 4 - provision: packages, then macOS defaults
say "brew bundle"
brew bundle --file "$HOME/.config/dotfiles/Brewfile" || _bundle_failed=1
say "macos defaults"
zsh "$HOME/.config/dotfiles/macos.zsh"

if [ "${_bundle_failed:-0}" = 1 ]; then die "brew bundle had failures - see $LOG"; fi
say "done - restart your shell:  exec zsh -l"
