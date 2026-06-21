# dotfiles

> Operating instructions for this `dotfiles` repo, for humans and coding agents.
> Git tracking follows the [DeVault convention][dv-dot] (`gitignore *` + force-add).

## Shape

In short: `$HOME` is the repo, `.gitignore` is a single `*`,
track by `git add -f`, files in place (no symlinks, no alias, no manager). zsh entry files sit
at `$HOME`, authored modules under `~/.zsh/`, secret values in the macOS keychain.

## Where things go

The one operational mirror of the spec's layout, kept here as the most-used lookup:

| Thing                                                     | Home                                             |
|-----------------------------------------------------------|--------------------------------------------------|
| universal env (not `PATH`)                                | `~/.zshenv`                                      |
| `PATH`, `brew shellenv`                                   | `~/.zprofile` (after `path_helper`)              |
| aliases, options, prompt, keybinds                        | a topic `~/.zsh/<topic>.zsh`                     |
| functions                                                 | inline in a module, or `~/.zsh/functions/<name>` |
| completions                                               | `~/.zsh/completions/_<command>`                  |
| machine-local lines + secret wiring                       | `~/.zsh/local.zsh` (untracked, sourced last)     |
| secret values                                             | macOS `environment` keychain                     |
| per-tool config                                           | `~/.config/<tool>/`                              |
| provisioning (Brewfile, bootstrap, macos.zsh, duti, test) | `~/.config/dotfiles/`                            |
| CI workflow                                               | `~/.github/workflows/test.yml`                   |
| personal executables                                      | `~/.local/bin/`                                  |

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

## Review

A periodic pass to undo drift, things get misplaced, misnamed, duplicated, or rot as tools
come and go. Work in order; each step is idempotent.

1. Tracking and secrets
   1. `git ls-files`; remove anything that should not be tracked (history, caches, `.DS_Store`, `local.zsh`).
   2. scan tracked files: `git grep -iE 'KEY|TOKEN|SECRET|PASSWORD'`. For each hit, judge: a long opaque value is a leak (untrack the file, move the value to the keychain and the wiring to `~/.zsh/local.zsh`, then rotate); a bare variable name wired through `load_secret` is fine.
   3. confirm `~/.zsh/local.zsh` is untracked.
2. Placement (move each to its home per Where things go)
   1. `PATH`/`brew` lines outside `~/.zprofile`: move to `~/.zprofile`.
   2. machine-specific lines in tracked modules: move to `~/.zsh/local.zsh`.
   3. loose zsh at `$HOME` that is not an entry file: move into a `~/.zsh/` module.
3. Naming
   1. each `~/.zsh/functions/<name>` defines exactly the function `<name>`; rename mismatches.
   2. each completion is `~/.zsh/completions/_<command>`.
   3. module names are topical, not dumping grounds.
4. Deduplicate (define once)
   1. find repeats across modules (same alias, function, or export defined twice).
   2. keep one definition, delete the rest.
5. Order within each file
   1. group related entries under a `#` header, one blank line between groups.
   2. order groups and entries by frequency, most-used first.
6. Prune rot
   1. drop aliases or functions whose tool is gone (`command -v` fails).
   2. drop `PATH` entries to nonexistent dirs.
   3. delete commented-out and dead blocks.
   4. split any module past ~100 lines into a topic; collapse trivially short ones back inline.
7. Provisioning
   1. Brewfile: `brew bundle check --file ~/.config/dotfiles/Brewfile` flags entries no longer installed; `brew bundle cleanup --file ~/.config/dotfiles/Brewfile` flags installed packages missing from it. Reconcile both.
   2. `macos.zsh` Dock list: drop a pinned app when its cask leaves the Brewfile (a missing one is skipped silently). `duti`: drop lines only if the `zed` cask is removed.
   3. `.github/workflows/test.yml`: keep the runner label and asserts in step with the spec.
   4. `~/.local/bin`: remove scripts that are dead or superseded.
8. Verify
   1. `zsh -lic 'exit'` returns 0 with empty stderr.
   2. `git status` clean apart from intended changes; commit.

[dv-dot]: https://drewdevault.com/2019/12/30/dotfiles.html
[tart]: https://tart.run
