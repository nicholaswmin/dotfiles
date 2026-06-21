# dotfiles

> Operating instructions for this `dotfiles` repo, for humans and coding agents.
> Git tracking follows the [DeVault convention][dv-dot] (`gitignore *` + force-add).

## Shape

In short: `$HOME` is the repo, `.gitignore` is a single `*`,
track by `git add -f`, files in place (no symlinks, no alias, no manager). zsh entry files sit
at `$HOME`, authored modules under `~/.zsh/`, secret values in the macOS keychain.

## Tracking

- Track: `git add -f <path>`, then `git commit`. A plain `git add` is a no-op (the `*` ignores it).
- Never commit a secret value or a machine-local line. If one lands in a tracked file, untrack it and rotate.
- `git status` shows only intended changes; `git ls-files` is the source of truth.

## Testing

- Requires [Tart][tart] on Apple Silicon: `brew install cirruslabs/cli/tart`.
- `sh .config/dotfiles/test/test.sh` restores the dotfiles onto a brand-new clean macOS VM end-to-end, runs bootstrap twice to prove the restore is idempotent, and asserts a working machine.
- It MUST pass before relying on a change to the bootstrap or the tracked layout (it validates the pushed state).

## Commit

- Message: `{feat|fix}: <subject>`, lowercase, subject 1-4 words. No body, no trailers, no footers.
- Author is your own git identity; never `--author`, and never an AI trailer (`Co-Authored-By`, "Generated with").
- Commits are signed (your git `commit.gpgsign`); do not disable it.
- Run the test first when the change touches install or layout.

## Code Review

Philosophy:

- [DeVault][dv-dot]-style minimal dotfiles: `$HOME` is the repo, `.gitignore`
  is `*`, files in place, no framework or manager
- [PoLa][pola]-friendly zsh: a predictable, least-astonishment structure that
  grows only when earned

Target environment: macOS 26.2+ and zsh 5.9+ only.

Tooling: `shellcheck` the POSIX sh (`bootstrap.sh`, `test/*.sh`); `zsh -n` the
zsh files (shellcheck has no zsh support).

zsh style:
- prefer builtins, globs (`(N)`), and parameter expansion over `sed`/`cat`/`ls`;
  use `[[ ]]` for tests and early returns over deep nesting
- scripts open with `emulate -L zsh` + local `setopt`; quote expansions; favour
  `print -r --` over `echo`

Before reviewing, read the latest authoritative docs for any component a change
touches.

Review each affected flow thoroughly, ensuring:

- the dotfiles restore stays in a good working state
- only generic, dotfiles-relevant items are captured
- the philosophy and structure are preserved, without fragmenting or churning
  the conventions
- all documentation is consistent and up to date

The layout to preserve:

```text
$HOME/                         # the repo itself, a non-bare git checkout
+-- .zshenv                    # read first; universal env, never PATH
+-- .zprofile                  # login; PATH + brew shellenv, after path_helper
+-- .zshrc                     # interactive; sources ~/.zsh/, then local.zsh
+-- .zsh/
|   +-- <topic>.zsh            # aliases, options, prompt; sourced in order
|   +-- secrets.zsh            # load_secret/secret helpers (tracked)
|   +-- local.zsh              # machine-local + secret wiring (untracked)
|   +-- functions/<name>       # one autoloaded function per file, named <name>
|   +-- completions/_<command> # one completion per command
+-- .config/
|   +-- git/{config,ignore}    # XDG git config; ~/.gitconfig must not exist
|   +-- <tool>/                # per-tool XDG config
|   +-- dotfiles/              # Brewfile, bootstrap.sh, macos.zsh, duti, test/
+-- .github/workflows/test.yml # CI: restore on a clean runner
+-- .local/bin/                # personal executables, on PATH via .zprofile
+-- .gitignore                 # a single *; track via git add -f
```

In addition to your own review, consider each of the following:

- secrets stay in the macOS keychain, wired in untracked `~/.zsh/local.zsh`; a
  secret value or machine-local line in a tracked file is a leak
- `$HOME` is the repo under a `*` ignore: track only via `git add -f`, never
  history, caches, or other machine-local or ephemeral files
- `bootstrap.sh` is POSIX sh and stays idempotent; `PATH` and `brew shellenv`
  belong in `.zprofile`, login-scoped
- modules are `~/.zsh/<topic>.zsh`, autoloaded `functions/<name>`, completions
  `~/.zsh/completions/_<command>`; define each thing once
- `assert.sh` is the single definition of a working machine; do not weaken it

Double-check **each and every finding**: each must be real and material.
Drop filler, restatements, and nits a formatter already catches.

[dv-dot]: https://drewdevault.com/2019/12/30/dotfiles.html
[pola]: https://en.wikipedia.org/wiki/Principle_of_least_astonishment
[tart]: https://tart.run
