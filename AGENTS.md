# dotfiles

> Operating instructions for this `dotfiles` repo, for humans and coding agents.
> Git tracking follows the [DeVault convention][dv-dot]: `gitignore *` plus
> force-add.

> [!CAUTION]
> This is the canonical dotfiles repository. A separate `.dots` repository may
> exist on a machine; it is deprecated. Never read, edit, sync, or conflate it
> with this one.

## Shape

- `$HOME` is the repo; `.gitignore` is a single `*`, track with `git add -f`
- files in place: no symlinks, no aliases, no manager
- zsh entry files at `$HOME`, authored modules under `~/.zsh/`
- secrets in the macOS keychain

## Tracking

- Track: `git add -f <path>`, then `git commit`. A plain `git add` is a no-op
  because the `*` ignores it.
- Never commit secrets or machine-local lines; if one lands, untrack and rotate.
- Track only intended files; never history, caches, or ephemeral state.
- `git status` shows only intended changes; `git ls-files` is the source of
  truth.

## Testing

- Requires [Tart][tart] on Apple Silicon: `brew install cirruslabs/cli/tart`.
- `sh .config/dotfiles/test/test.sh` restores the dotfiles onto a brand-new
  clean macOS VM end-to-end, runs bootstrap twice to prove the restore is
  idempotent, and asserts a working machine; do not weaken its assertions.
- It MUST pass before relying on a change to the bootstrap or the tracked
  layout; it validates the pushed state.

## Commit

- Message: `{feat|fix}: <subject>`, lowercase, subject 1-4 words. No body, no
  trailers, no footers.
- Author is your own git identity; never `--author`, and never an AI trailer
  such as `Co-Authored-By` or "Generated with".
- Commits are signed via your git `commit.gpgsign`; do not disable it.
- Run the test first when the change touches install or layout.

## GitHub

GitHub-side settings, applied with `gh` so they stay reproducible:

- Secret scanning + push protection enforce the keychain rule at the git layer;
  a recognised secret cannot be pushed.

```sh
repo=nicholaswmin/dotfiles
gh api -X PATCH "repos/$repo" --input - <<'JSON'
{ "security_and_analysis": {
  "secret_scanning":                 { "status": "enabled" },
  "secret_scanning_push_protection": { "status": "enabled" }
} }
JSON
```

- `main` is guarded by the `protect-main` ruleset: force-push and delete are
  blocked so history cannot be clobbered. No required checks or reviews and no
  bypass, so direct pushes stay free and the guard binds the solo owner too.

```sh
repo=nicholaswmin/dotfiles
gh api -X POST "repos/$repo/rulesets" --input - <<'JSON'
{
  "name": "protect-main",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] }
  },
  "rules": [ { "type": "deletion" }, { "type": "non_fast_forward" } ]
}
JSON
```

- Pages publishes the `docs` workflow build via the GitHub Actions source, so
  the rendered README ships on push. One-time; a re-run returns 409 once set.

```sh
repo=nicholaswmin/dotfiles
gh api -X POST "repos/$repo/pages" --input - <<'JSON'
{ "build_type": "workflow" }
JSON
```

## Code Review

Philosophy:

- [DeVault][dv-dot]-style minimal dotfiles: `$HOME` is the repo, `.gitignore`
  is `*`, files in place, no framework or manager
- [PoLa][pola]-friendly zsh: a predictable, least-astonishment structure that
  grows only when earned

Target environment: macOS 26.2+ and zsh 5.9+ only.

Tooling:
- `shellcheck` the POSIX sh: `bootstrap.sh`, `test/*.sh`
- `zsh -n` the zsh files; shellcheck has no zsh support

zsh style:
- prefer builtins, globs such as `(N)`, and parameter expansion over
  `sed`/`cat`/`ls`; use `[[ ]]` for tests and early returns over deep nesting
- scripts open with `emulate -L zsh` + local `setopt`; quote expansions; favour
  `print -r --` over `echo`

Before reviewing, read the latest authoritative docs for any component touched.

Review each affected flow thoroughly, ensuring:

- the dotfiles restore stays in a good working state
- only generic, dotfiles-relevant items are captured
- values are evergreen; a version is pinned only where floating would be harmful:
  - resolve at restore time, e.g. `fnm install --lts` not `fnm install 26`
  - pin only where moving the version is the hazard, e.g. `postgresql@18`
  - version floors like `macOS 26.2+` are fine; latest-pins are not
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
|   +-- <topic>.zsh            # aliases, options, prompt; sourced in order, defined once
|   +-- secrets.zsh            # load_secret/secret helpers, tracked
|   +-- local.zsh              # machine-local + secret wiring, untracked
+-- .config/
|   +-- git/{config,ignore}    # XDG git config; ~/.gitconfig must not exist
|   +-- <tool>/                # per-tool XDG config
|   +-- dotfiles/              # restore + setup
+-- .github/workflows/         # CI: test + docs
+-- .local/bin/                # personal executables, on PATH via .zprofile
+-- .gitignore                 # a single *; track via git add -f
```

Double-check **each and every finding**: each must be real and material.
Drop filler, restatements, and nits a formatter already catches.

[dv-dot]: https://drewdevault.com/2019/12/30/dotfiles.html
[pola]: https://en.wikipedia.org/wiki/Principle_of_least_astonishment
[tart]: https://tart.run
