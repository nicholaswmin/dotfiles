#!/usr/bin/env sh
# test: restore the working tree onto a clean Tart VM, run bootstrap twice for
# idempotency, then assert. needs tart; sshpass auto-installs.
set -eu

IMAGE="ghcr.io/cirruslabs/macos-tahoe-base:latest"
VM="dotfiles-test-$$"
BUNDLE="${TMPDIR:-/tmp}/dotfiles-$$.bundle"
SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# logging: stdout+stderr to a timestamped log; fd 3 stays the terminal for progress.
LOG="${TMPDIR:-/tmp}/dotfiles-test-$(date +%Y%m%d-%H%M%S).log"
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

# prerequisites
command -v tart    >/dev/null 2>&1 || die "tart missing - brew install cirruslabs/cli/tart"
command -v sshpass >/dev/null 2>&1 || { say "installing sshpass"; brew install sshpass; }

# shellcheck disable=SC2086  # $SSHOPTS expands to multiple flags by design
run() { sshpass -p admin ssh $SSHOPTS "admin@$IP" "$@"; }
# shellcheck disable=SC2086  # $SSHOPTS expands to multiple flags by design
put() { sshpass -p admin scp $SSHOPTS "$1" "admin@$IP:$2"; }

cleanup() {
  tart stop "$VM" >/dev/null 2>&1 || true
  tart delete "$VM" >/dev/null 2>&1 || true
  rm -f "$BUNDLE"
  git -C "${REPO_ROOT:-.}" update-ref -d refs/heads/_dotfiles-test 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# 1 - bundle the current working tree under a throwaway ref
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"
ref=$(git stash create || true); [ -n "$ref" ] || ref=$(git rev-parse HEAD)
git update-ref refs/heads/_dotfiles-test "$ref"
git bundle create "$BUNDLE" _dotfiles-test

# 2 - clean VM
say "clone $IMAGE -> $VM"
tart clone "$IMAGE" "$VM"
say "boot"
tart run --no-graphics "$VM" >/dev/null 2>&1 &

say "wait for ssh"
IP=
i=0
while [ "$i" -lt 60 ]; do
  IP=$(tart ip "$VM" 2>/dev/null || true)
  [ -n "$IP" ] && run true >/dev/null 2>&1 && break
  i=$((i + 1)); sleep 5
done
[ -n "$IP" ] || die "VM never accepted ssh"

# 3 - restore THIS working tree via the real bootstrap twice for idempotency, then assert
say "restore (current working tree) on clean VM"
put "$BUNDLE" /tmp/dotfiles.bundle
run "git clone -q --branch _dotfiles-test /tmp/dotfiles.bundle /tmp/seed \
  && DOTFILES_REPO=/tmp/dotfiles.bundle DOTFILES_REF=_dotfiles-test sh /tmp/seed/.config/dotfiles/bootstrap.sh"
say "restore again (idempotent: a re-run must be a clean no-op)"
run "DOTFILES_REPO=/tmp/dotfiles.bundle DOTFILES_REF=_dotfiles-test sh /tmp/seed/.config/dotfiles/bootstrap.sh"
say "assert"
run "DOTFILES_REPO=/tmp/dotfiles.bundle sh \$HOME/.config/dotfiles/test/assert.sh"

say "pass"
