#!/bin/bash

#############################################################
# macOS System Settings Configuration
#############################################################

configure_macos_settings() {
    log "Configuring macOS system settings..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] Would configure macOS settings"
        return 0
    fi
    
    # Close System Preferences to prevent conflicts
    osascript -e 'quit app "System Preferences"' 2>/dev/null || true
    
    ###################
    # Desktop & Documents in iCloud
    ###################
    log "Configuring iCloud Drive for Desktop & Documents..."
    # This requires user to be signed into iCloud
    defaults write com.apple.finder FXICloudDriveEnabled -bool true
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    defaults write com.apple.finder FXICloudDriveDesktop -bool true
    defaults write com.apple.finder FXICloudDriveDocuments -bool true
    
    ###################
    # Disable Desktop Widgets
    ###################
    log "Disabling desktop widgets..."
    defaults write com.apple.WindowManager StandardHideWidgets -bool true
    defaults write com.apple.WindowManager HideWidgets -bool true
    
    ###################
    # Finder Settings
    ###################
    log "Configuring Finder settings..."
    
    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Set default Finder location to home folder
    defaults write com.apple.finder NewWindowTarget -string "PfLo"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
    
    # Search current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    
    # Disable warning when changing file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Enable spring loading for directories
    defaults write NSGlobalDomain com.apple.springing.enabled -bool true
    
    # Remove delay for spring loading
    defaults write NSGlobalDomain com.apple.springing.delay -float 0
    
    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    
    ###################
    # Dock Settings
    ###################
    log "Configuring Dock settings..."
    
    # Enable Dock auto-hide
    defaults write com.apple.dock autohide -bool true
    
    # Remove auto-hide delay
    defaults write com.apple.dock autohide-delay -float 0
    
    # Make animation faster
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    
    # Set Dock icon size
    defaults write com.apple.dock tilesize -int 48
    
    # Enable magnification
    defaults write com.apple.dock magnification -bool true
    
    # Set magnification size
    defaults write com.apple.dock largesize -int 64
    
    # Minimize windows using scale effect
    defaults write com.apple.dock mineffect -string "scale"
    
    # Don't show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false
    
    # Show indicator lights for open applications
    defaults write com.apple.dock show-process-indicators -bool true
    
    ###################
    # Screenshots
    ###################
    log "Configuring screenshot settings..."
    
    # Create Screenshots folder if it doesn't exist
    mkdir -p "${HOME}/Screenshots"
    
    # Save screenshots to custom folder
    defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
    
    # Save screenshots in PNG format
    defaults write com.apple.screencapture type -string "png"
    
    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
    
    ###################
    # General UI/UX
    ###################
    log "Configuring general UI/UX settings..."
    
    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    
    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    
    # Disable the "Are you sure you want to open this application?" dialog
    defaults write com.apple.LaunchServices LSQuarantine -bool false
    
    # Enable full keyboard access for all controls
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    
    # Enable subpixel font rendering on non-Apple LCDs
    defaults write NSGlobalDomain AppleFontSmoothing -int 2
    
    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    
    ###################
    # Restart affected apps
    ###################
    log "Restarting affected applications..."
    
    for app in "Finder" "Dock" "SystemUIServer"; do
        killall "${app}" 2>/dev/null || true
    done
    
    success "macOS settings configured successfully"
    info "Some settings may require a restart to take full effect"
}