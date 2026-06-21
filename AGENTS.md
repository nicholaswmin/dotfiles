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

## Code Review

Guidance for an automated reviewer on pull requests. This is a personal macOS
dotfiles tree where `$HOME` is the git repo; weigh these invariants over style
nits a formatter or linter already catches.

Target environment: macOS 26.2+ and zsh 5.9+ only; assume no earlier version
or other platform. Strongly recommended: before reviewing, read the latest
authoritative docs for any component a change touches.

Expected layout - protect it, and flag anything that lands elsewhere:

```text
$HOME/                         # the repo itself, a non-bare git checkout
+-- .zshenv                    # read first; universal env, never PATH
+-- .zprofile                  # login; PATH + brew shellenv, after path_helper
+-- .zshrc                     # interactive; sources ~/.zsh/, then local.zsh
+-- .zsh/
|   +-- <topic>.zsh            # topic modules, sourced in order
|   +-- secrets.zsh            # load_secret/secret helpers (tracked)
|   +-- local.zsh              # machine-local + secret wiring (untracked)
|   +-- functions/<name>       # one autoloaded function per file, named <name>
|   +-- completions/_<command> # one completion per command
+-- .config/
|   +-- git/{config,ignore}    # XDG git config; ~/.gitconfig must not exist
|   +-- dotfiles/              # Brewfile, bootstrap.sh, macos.zsh, duti, test/
+-- .github/workflows/test.yml # CI: restore on a clean runner
+-- .gitignore                 # a single *; track via git add -f
```

- Secrets come first.
  - Any secret value, token, or machine-specific line in a tracked file is a
    finding.
  - Secrets live in the macOS keychain, wired in untracked `~/.zsh/local.zsh`.
  - A bare name through `load_secret` is fine; an opaque value is a leak.
- Tracking is explicit.
  - Everything is force-added against a `*` ignore, so scrutinise new tracked
    files.
  - Machine-local or ephemeral state (history, caches, `.DS_Store`,
    `local.zsh`) must never be committed.
- The restore stays idempotent.
  - `bootstrap.sh` and `macos.zsh` must be safe to re-run and assume no prior
    state.
  - A new unguarded destructive or non-idempotent step is a finding;
    `checkout -f` is deliberate.
- The shell split holds.
  - `bootstrap.sh` is POSIX sh, run before anything is installed: flag
    bashisms or reliance on not-yet-present tools.
  - `PATH` and `brew shellenv` belong in `.zprofile`.
  - Prefer modern, standards-first shell over legacy shims; assume the latest
    OS.
- Aliases and functions follow convention.
  - Topic modules are `~/.zsh/<topic>.zsh`, sourced in order; keep them
    topical, not dumping grounds, and split a module past ~100 lines.
  - An autoloaded function is `~/.zsh/functions/<name>` defining exactly
    `<name>`; a completion is `~/.zsh/completions/_<command>`.
  - Define each alias, function, or export once; flag duplicates and any
    whose tool is gone (`command -v` fails).
  - Machine-specific lines belong in `local.zsh`, never a tracked module.
- Docs stay aligned.
  - `README.md` and `AGENTS.md` must reflect any change to behaviour, layout,
    or commands; flag drift between the docs and the code.
- The contract is protected.
  - `assert.sh` is the single definition of a working machine.
  - Flag changes to bootstrap, the Brewfile, the layout, or entry files that
    weaken or bypass it.
- Additions earn their place.
  - Prefer deletion; question speculative options, fallbacks, or handling for
    impossible cases.
  - New code should fit the surrounding idiom, not merely work.

Be specific and explain the why; point to the safer pattern, acknowledge good
ones, and ask when intent is unclear. Then re-check every finding in depth
before posting: each must be real, material, and actionable. Drop anything that
is filler, a restatement, or a nit the tooling already catches.

[dv-dot]: https://drewdevault.com/2019/12/30/dotfiles.html
[tart]: https://tart.run
