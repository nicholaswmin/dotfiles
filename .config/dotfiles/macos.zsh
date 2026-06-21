#!/usr/bin/env zsh
# macos.zsh - apply macOS defaults after brew bundle: Finder, Terminal, Dock,
# Spotlight, and Zed file associations. Idempotent; missing apps are skipped.
emulate -L zsh
setopt err_exit pipe_fail
say() { print -u2 -r -- "==> $*"; }

# Finder
say finder
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
killall Finder 2>/dev/null || true

# Terminal - strip title clutter
say terminal
for k in ShowActiveProcessInTitle ShowActiveProcessArgumentsInTitle \
         ShowTTYNameInTitle ShowRepresentedURLInTitle \
         ShowWindowSettingsNameInTitle ShowDimensionsInTitle \
         ShowShellCommandInTitle TitleDisplaysCustom TitleDisplaysDeviceName \
         TitleDisplaysSettingsName TitleDisplaysShellPath TitleDisplaysWindowSize
do
  defaults write com.apple.Terminal $k -bool false
done

# Dock - pin installed apps, skip any that are absent
say dock
dock=(
  /Applications/Zed.app
  /Applications/Spotify.app
  /Applications/Slack.app
  /Applications/Claude.app
  /Applications/ChatGPT.app
  "/System/Applications/System Settings.app"
  /Applications/Safari.app
  /System/Applications/Utilities/Terminal.app
)
defaults write com.apple.dock persistent-apps -array
for app in $dock; do
  [[ -e $app ]] || continue
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
done
killall Dock 2>/dev/null || true

# Spotlight - exclude the projects dir
say spotlight
proj=${PROJECTS_DIR:-$HOME/Projects}
if [[ -d $proj ]] && ! defaults read com.apple.Spotlight Exclusions 2>/dev/null | grep -qF "$proj"; then
  defaults write com.apple.Spotlight Exclusions -array-add "$proj"
  killall mds 2>/dev/null || true
fi

# Editor - Zed as default for code files (associations in the sibling `duti` file).
# Skipped under CI - GitHub runners do not honour LaunchServices handler changes.
say editor
if [[ -z "${CI:-}" ]] && command -v duti >/dev/null; then
  duti "${0:A:h}/duti" || say "duti: some associations not applied (see log)"
fi
