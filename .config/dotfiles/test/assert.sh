#!/usr/bin/env sh
# assert.sh - the single definition of "a working machine", run after a restore.
# bootstrap leaves it in $HOME, so test.sh runs it in the VM and CI on the runner.
set -eu
fail() { printf 'assert: %s\n' "$*" >&2; exit 1; }

REPO="${DOTFILES_REPO:-https://github.com/nicholaswmin/dotfiles}"

# login shell loads, brew is on PATH, the Brewfile is satisfied
zsh -lic exit                                                    || fail "login shell failed to load"
zsh -lic 'command -v brew >/dev/null'                           || fail "brew not on PATH"
zsh -lic 'brew bundle check --file ~/.config/dotfiles/Brewfile' || fail "brew bundle incomplete"

# entry files in place
test -f ~/.zshenv && test -f ~/.zprofile && test -f ~/.zshrc    || fail "entry files missing"

# the repo: $HOME is the worktree root, origin is canonical (raw url), tree is clean
[ "$(git -C "$HOME" rev-parse --show-toplevel)" = "$HOME" ]      || fail "\$HOME is not the repo root"
[ "$(git -C "$HOME" config --get remote.origin.url)" = "$REPO" ] || fail "unexpected origin"
[ -z "$(git -C "$HOME" status --porcelain)" ]                   || fail "repo dirty after restore"

# storage + git-config invariants
[ "$(cat ~/.gitignore)" = '*' ]                                 || fail ".gitignore is not exactly *"
test ! -e ~/.gitconfig                                          || fail "~/.gitconfig present (overrides XDG config)"
[ -z "$(git -C "$HOME" config --get core.excludesfile || true)" ] || fail "core.excludesfile is set"
git -C "$HOME" config --get gpg.format      | grep -qx ssh      || fail "gpg.format not ssh"
git -C "$HOME" config --get commit.gpgsign  | grep -qx true     || fail "commit signing not enabled"
git -C "$HOME" config --get user.signingkey | grep -q .         || fail "signing key not configured"

# files that must never be tracked
[ -z "$(git -C "$HOME" ls-files .zsh/local.zsh .zsh_history .zcompdump .DS_Store)" ] \
  || fail "a machine-local or ephemeral file is tracked"

# the editor associations were actually applied
if command -v duti >/dev/null; then
  duti -x sh 2>/dev/null | grep -qi zed                         || fail "duti: .sh not mapped to Zed"
fi

echo "assert: ok"
