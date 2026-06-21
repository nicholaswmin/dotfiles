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
+-- .zsh/             *.zsh modules + functions/ + completions/
|   +-- secrets.zsh   load_secret/secret helpers
|   +-- local.zsh     untracked; machine-local + secrets, last
+-- .config/
|   +-- git/          config, ignore
|   +-- dotfiles/     Brewfile, bootstrap.sh, macos.zsh, duti, test/
+-- .local/bin/       executables
```

## restore

needs [Xcode Command Line Tools][xcode]. then:

```sh
curl -fsSL https://raw.githubusercontent.com/nicholaswmin/dotfiles/main/.config/dotfiles/bootstrap.sh -o /tmp/bootstrap.sh
sh /tmp/bootstrap.sh
exec zsh -l
```

installs homebrew, checks the repo into `$HOME`, runs `brew bundle` and macOS
`defaults`. checkout overwrites colliding stock files, so back up first.

## after

bootstrap skips anything secret or machine-bound. on a fresh box:

- ssh + signing key at `~/.ssh/id_ed25519_signing.pub`, added to GitHub
- `gh auth login`
- `aws` and `cloudflared` logins
- create the `environment` keychain, add keys like `brave`
- `fnm install --lts && fnm default lts-latest`

## tracking

everything in `$HOME` is ignored; force-add what to track. `git ls-files` is
the manifest.

```sh
git add -f ~/.config/foo
git commit -m "feat: track foo"
```

## secrets

secrets live in the macOS keychain, never in the repo; wire them in untracked
`~/.zsh/local.zsh`.

```sh
load_secret OPENROUTER_API_KEY openrouter
curl -fsS -H "Authorization: Bearer $(secret CLOUDFLARE_API_TOKEN)" "$api"
```

## tests

needs [tart][tart].

```sh
brew install cirruslabs/cli/tart
sh .config/dotfiles/test/test.sh
```

[gh-author]: https://github.com/nicholaswmin
[xcode]: https://developer.apple.com/xcode/
[tart]: https://tart.run
