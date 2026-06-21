# dotfiles

[nicholaswmin][gh-author] macOS config; in git, in place, no symlinks.

## layout

`$HOME` is the repo; files sit in place, the rest is XDG.

```
~/
+-- .gitignore        a single line: *
+-- .zshenv           read first; env, not PATH
+-- .zprofile         login; PATH + brew shellenv
+-- .zshrc            interactive; sources ~/.zsh/, then local.zsh
+-- .zsh/             authored modules
|   +-- *.zsh         topic modules, sourced in order
|   +-- secrets.zsh   load_secret/secret helpers
|   +-- local.zsh     untracked; machine-local + secret wiring, sourced last
|   +-- completions/  _<command> on fpath
|   +-- functions/    autoloaded, one-per-file
+-- .config/
|   +-- git/          config, ignore (XDG)
|   +-- dotfiles/     Brewfile, bootstrap.sh, macos.zsh, duti, test/
+-- .local/bin/       executables
```

## restore/initialise

assumes installed [Xcode Command Line Tools][Xcode-tools]

```sh
curl -fsSL https://raw.githubusercontent.com/nicholaswmin/dotfiles/main/.config/dotfiles/bootstrap.sh -o /tmp/bootstrap.sh
sh /tmp/bootstrap.sh
```

this provisions a fresh macOS box end-to-end:

- installs `homebrew`
- checks the repo into `$HOME`
- runs `brew bundle` and the macOS `defaults`
- then restart the shell: `exec zsh -l`

> **note:** checkout overwrites colliding stock files;
> back up anything you care about first.

> **note:** fetch and clone stay anonymous HTTPS; `git push` uses SSH (via
> `pushInsteadOf`), so set up your SSH + signing key before pushing.

## tracking files

everything in `$HOME` is ignored by default, so force-add what you want to track.

```sh
git add -f ~/.config/foo
git commit -m "feat: track foo"
```

> **note:** `.gitignore` is a single `*`; `git ls-files` is the manifest of what is tracked.

## restoring files

`git restore` returns a tracked file to its committed state.

```sh
git restore ~/.zshrc   # discard local edits to one file
git restore .          # reset the whole tracked tree
```

## secrets

secrets live in the macOS keychain, never in the repo.
wire them in `~/.zsh/local.zsh`, which stays untracked.

```sh
load_secret OPENROUTER_API_KEY openrouter   # export, fails loud
curl -fsS -H "Authorization: Bearer $(secret CLOUDFLARE_GLOBAL_API_TOKEN)" "$api"   # read on demand
```

## tests

requires [tart][tart-url]:

```sh
brew install cirruslabs/cli/tart
sh .config/dotfiles/test/test.sh
```

[gh-author]: https://github.com/nicholaswmin
[Xcode-tools]: https://developer.apple.com/xcode/
[tart-url]: https://tart.run
