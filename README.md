# dotfiles

[nicholaswmin][gh-author] macOS config; in git, in place, no symlinks.

## layout

`$HOME` is the repo; files sit in place, the rest is XDG.

```text
~/
+-- .gitignore        a single line: *
+-- .zshenv           read first; env, not PATH
+-- .zprofile         login; PATH + brew shellenv
+-- .zshrc            interactive; sources ~/.zsh/, then local.zsh
+-- .zsh/             modules (*.zsh) + functions/ + completions/
|   +-- secrets.zsh   load_secret/secret helpers
|   +-- local.zsh     untracked; machine-local + secret wiring, last
+-- .config/
|   +-- git/          config, ignore (XDG)
|   +-- dotfiles/     Brewfile, bootstrap.sh, macos.zsh, duti, test/
+-- .local/bin/       executables
```

## restore

assumes [Xcode Command Line Tools][Xcode-tools]; provisions a fresh macOS box
end-to-end (Homebrew, the repo into `$HOME`, `brew bundle`, macOS `defaults`):

```sh
curl -fsSL https://raw.githubusercontent.com/nicholaswmin/dotfiles/main/.config/dotfiles/bootstrap.sh -o /tmp/bootstrap.sh
sh /tmp/bootstrap.sh
exec zsh -l
```

> **note:** checkout overwrites colliding stock files; back up first. Fetch and
> clone stay anonymous HTTPS; `git push` uses SSH (`pushInsteadOf`), so set up
> your SSH + signing key before pushing.

## tracking

everything in `$HOME` is ignored, so force-add what to track (`git ls-files` is
the manifest):

```sh
git add -f ~/.config/foo
git commit -m "feat: track foo"
```

## secrets

secrets live in the macOS keychain, never in the repo; wire them in untracked
`~/.zsh/local.zsh`:

```sh
load_secret OPENROUTER_API_KEY openrouter   # export, fails loud
curl -fsS -H "Authorization: Bearer $(secret CLOUDFLARE_GLOBAL_API_TOKEN)" "$api"
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
