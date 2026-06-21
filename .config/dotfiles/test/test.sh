#!/usr/bin/env sh
# test - restore the CURRENT working tree onto a brand-new machine and assert it.
# Runs the real bootstrap TWICE - the restore MUST be idempotent, a re-run is a
# clean no-op - then the shared assert.sh. Bundles the working tree and points
# bootstrap at the bundle in a clean Tart VM (DOTFILES_REPO/REF), so it tests THIS
# checkout, not main. Requires tart; sshpass is auto-installed from homebrew-core.
set -eu

IMAGE="ghcr.io/cirruslabs/macos-tahoe-base:latest"
VM="dotfiles-test-$$"
BUNDLE="${TMPDIR:-/tmp}/dotfiles-$$.bundle"
SSHOPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# --- logging: full transcript to a timestamped file; progress to the terminal --
# fd 3 stays the terminal (coloured ==> progress); stdout+stderr go to the log.
# No pipe, so the exit status is preserved. Colour tested on fd 3.
LOG="${TMPDIR:-/tmp}/dotfiles-test-$(date +%Y%m%d-%H%M%S).log"
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

# prerequisites
command -v tart    >/dev/null 2>&1 || die "tart missing - brew install cirruslabs/cli/tart"
command -v sshpass >/dev/null 2>&1 || { say "installing sshpass"; brew install sshpass; }

run() { sshpass -p admin ssh $SSHOPTS "admin@$IP" "$@"; }
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

# 3 - restore THIS working tree via the real bootstrap, twice (idempotent), then assert
say "restore (current working tree) on clean VM"
put "$BUNDLE" /tmp/dotfiles.bundle
run "git clone -q --branch _dotfiles-test /tmp/dotfiles.bundle /tmp/seed \
  && DOTFILES_REPO=/tmp/dotfiles.bundle DOTFILES_REF=_dotfiles-test sh /tmp/seed/.config/dotfiles/bootstrap.sh"
say "restore again (idempotent: a re-run must be a clean no-op)"
run "DOTFILES_REPO=/tmp/dotfiles.bundle DOTFILES_REF=_dotfiles-test sh /tmp/seed/.config/dotfiles/bootstrap.sh"
say "assert"
run "DOTFILES_REPO=/tmp/dotfiles.bundle sh \$HOME/.config/dotfiles/test/assert.sh"

say "pass"
