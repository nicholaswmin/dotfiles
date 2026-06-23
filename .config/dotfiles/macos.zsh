#!/usr/bin/env zsh
# macos.zsh - apply macOS defaults + app setup after brew bundle.
# Idempotent; missing apps are skipped.
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

# Keyboard - fast repeat, full keyboard access
say keyboard
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Trackpad - tap to click + corner secondary-click; both built-in (laptop) and
# Magic (Bluetooth) domains so it restores on any Mac. Scroll dir is global.
say trackpad
for d in com.apple.AppleMultitouchTrackpad \
         com.apple.driver.AppleBluetoothMultitouch.trackpad
do
  defaults write $d Clicking -bool true
  defaults write $d TrackpadRightClick -bool true
  defaults write $d TrackpadCornerSecondaryClick -int 2
done
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Text input - disable smart substitutions and auto-correct
say text
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Screenshots - png to ~/Desktop, no window shadow
say screenshots
defaults write com.apple.screencapture location -string "$HOME/Desktop"
defaults write com.apple.screencapture type -string png
defaults write com.apple.screencapture disable-shadow -bool true
killall SystemUIServer 2>/dev/null || true

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

# Terminal theme - import the One Dark profile, set it default + startup.
# Import needs the GUI, so skip under CI; the defaults below are harmless there.
say "terminal theme"
if [[ -z "${CI:-}" ]] && ! defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -q "OneDark ="; then
  open "${0:A:h}/onedark.terminal" || say "terminal theme import skipped"
  for _ in {1..10}; do
    defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -q "OneDark =" && break
    sleep 0.5
  done
fi
defaults write com.apple.Terminal "Default Window Settings" -string OneDark
defaults write com.apple.Terminal "Startup Window Settings" -string OneDark

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

# Editor: Zed as the default for code files. Associations live in the sibling `duti` file.
# Skipped under CI - GitHub runners do not honour LaunchServices handler changes.
say editor
if [[ -z "${CI:-}" ]] && command -v duti >/dev/null; then
  duti "${0:A:h}/duti" || say "duti: some associations not applied (see log)"
fi
