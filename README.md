# dotfiles

[nicholaswmin][gh-author] macOS config

- repo sits at `$HOME`
- no dotfiles managers, no fancy commands, just `git *`
- min. architecture `.zsh`, conventional locations

the rest is [XDG][xdg-spec].

```sh
~/
+-- .gitignore        # ignore all (*)
+-- .zshenv           # env, not PATH
+-- .zprofile         # login; PATH + brew shellenv
+-- .zshrc            # interactive; sources ~/.zsh/ then local.zsh
+-- .zsh/             # *.zsh modules, functions, completions
|   +-- secrets.zsh   # load_secret/secret keychain helpers
|   +-- local.zsh     # untracked; machine-local secrets
+-- .config/
|   +-- git/          # config, ignore
|   +-- dotfiles/     # Brewfile, bootstrap.sh, macos.zsh, duti, test/
+-- .local/bin/       # executables
```

## restore

needs [Xcode Command Line Tools][xcode]. 

then:

```sh
curl -fsSL https://raw.githubusercontent.com/nicholaswmin/dotfiles/main/.config/dotfiles/bootstrap.sh -o /tmp/bootstrap.sh
sh /tmp/bootstrap.sh
exec zsh -l
```

1. installs homebrew
2. checks the repo into `$HOME`
3. runs `brew bundle` and macOS `defaults`. 

> **note:** overwrites colliding files, so grab a backup first.

### post-restore

mint the local stuff; mainly logins:

- ssh + signing key at `~/.ssh/id_ed25519_signing.pub`, added to GitHub
- `gh auth login`
- `aws` and `cloudflared` logins
- create the `environment` keychain, add keys like `brave`
- `fnm install --lts && fnm default lts-latest`

## daily driving

everything in `$HOME` is ignored.

- force-add what to track. 
- `git ls-files` is the manifest.

```sh
git add -f ~/.config/foo
git commit -m "feat: track foo"
git push
```

### secrets

secrets live in the macOS keychain; never in the repo.  
Wire them in untracked `~/.zsh/local.zsh`:

```sh
load_secret FOO_API_KEY ACME
curl -fsS -H "Authorization: Bearer $(secret FOO_API_KEY)" "$api"
```

## tests

needs [tart][tart].

```sh
brew install cirruslabs/cli/tart
sh .config/dotfiles/test/test.sh
```

[xdg-spec]: https://specifications.freedesktop.org/basedir/latest/
[gh-author]: https://github.com/nicholaswmin
[xcode]: https://developer.apple.com/xcode/
[tart]: https://tart.run
