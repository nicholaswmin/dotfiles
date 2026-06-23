# dotfiles

[nicholaswmin][gh-author] macOS config

[![test][test-badge]][test-runs] [![docs][docs-badge]][docs-runs]

- repo is `$HOME`
- no managers, no fancy commands, just `git *`
- minimal `.zsh`, conventional [XDG][xdg-spec] locations

```text
~/
+-- .gitignore        # ignore all via *
+-- .zshenv           # env, not PATH
+-- .zprofile         # login; PATH + brew shellenv
+-- .zshrc            # interactive; sources ~/.zsh/ then local.zsh
+-- .zsh/             # *.zsh modules
|   +-- secrets.zsh   # load_secret/secret keychain helpers
|   +-- local.zsh     # untracked; machine-local secrets
+-- .config/
|   +-- git/          # config, ignore
|   +-- dotfiles/     # restore + setup
+-- .local/bin/       # executables
```

## restore

ensure you have [Xcode Command Line Tools][xcode-clt]:

```sh
xcode-select --install
```

then:

```sh
curl -fsSL https://raw.githubusercontent.com/nicholaswmin/dotfiles/main/.config/dotfiles/bootstrap.sh -o /tmp/bootstrap.sh
sh /tmp/bootstrap.sh
exec zsh -l
```

1. installs Homebrew
2. checks the repo into `$HOME`
3. runs `brew bundle` and macOS `defaults`

> **note:** overwrites colliding files, so grab a backup first.

### post-restore

mint the local stuff; mainly logins:

- ssh + signing key at `~/.ssh/id_ed25519_signing.pub`, added to GitHub
- `gh auth login`
- `aws` and `cloudflared` logins
- create the `environment` keychain, add your keys
- Spotlight in System Settings:
  - Search Results: keep only Documents + Files & Folders
  - Search Privacy: exclude `~/Projects`

## daily driving

all in `$HOME` ignored, opt-in deliberately.

### tracking files

- force-add what to track
- `git ls-files` is the manifest

```sh
git add -f ~/.config/foo
git commit -m "feat: track foo"
git push
```

### managing secrets

secrets live in the macOS keychain; never in the repo.  
Wire them in untracked `~/.zsh/local.zsh`:

```sh
load_secret FOO_API_KEY ACME
curl -fsS -H "Authorization: Bearer $FOO_API_KEY" "$api"
```

## tests

needs [Tart][tart].

```sh
brew install cirruslabs/cli/tart
sh .config/dotfiles/test/test.sh
```

[xdg-spec]: https://specifications.freedesktop.org/basedir/latest/
[gh-author]: https://github.com/nicholaswmin
[xcode-clt]: https://developer.apple.com/xcode/resources/
[tart]: https://tart.run
[test-badge]: https://github.com/nicholaswmin/dotfiles/actions/workflows/test.yml/badge.svg
[test-runs]: https://github.com/nicholaswmin/dotfiles/actions/workflows/test.yml
[docs-badge]: https://github.com/nicholaswmin/dotfiles/actions/workflows/docs.yml/badge.svg
[docs-runs]: https://github.com/nicholaswmin/dotfiles/actions/workflows/docs.yml
