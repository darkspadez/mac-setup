#!/bin/bash

#############################################################
# macOS System Settings Configuration
#############################################################

# Safe defaults write with error handling
safe_defaults() {
    local domain="$1"
    local key="$2"
    local type="$3"
    local value="$4"
    
    if defaults write "$domain" "$key" "-$type" "$value" 2>/dev/null; then
        return 0
    else
        warning "Failed to set $domain $key (may not be supported on this macOS version)"
        return 1
    fi
}

configure_macos_settings() {
    log "Configuring macOS system settings..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] Would configure macOS settings"
        return 0
    fi
    
    # Close System Settings/Preferences to prevent conflicts
    # Try both names for compatibility with different macOS versions
    osascript -e 'quit app "System Settings"' 2>/dev/null || true
    osascript -e 'quit app "System Preferences"' 2>/dev/null || true
    
    ###################
    # Desktop & Documents in iCloud
    ###################
    log "Configuring iCloud Drive for Desktop & Documents..."
    # This requires user to be signed into iCloud
    safe_defaults com.apple.finder FXICloudDriveEnabled bool true
    safe_defaults com.apple.finder FXEnableExtensionChangeWarning bool false
    safe_defaults com.apple.finder FXICloudDriveDesktop bool true
    safe_defaults com.apple.finder FXICloudDriveDocuments bool true
    
    ###################
    # Disable Desktop Widgets
    ###################
    log "Disabling desktop widgets..."
    safe_defaults com.apple.WindowManager StandardHideWidgets bool true || true
    safe_defaults com.apple.WindowManager HideWidgets bool true || true
    
    ###################
    # Finder Settings
    ###################
    log "Configuring Finder settings..."
    
    # Show hidden files
    safe_defaults com.apple.finder AppleShowAllFiles bool true
    
    # Show file extensions
    safe_defaults NSGlobalDomain AppleShowAllExtensions bool true
    
    # Show path bar
    safe_defaults com.apple.finder ShowPathbar bool true
    
    # Show status bar
    safe_defaults com.apple.finder ShowStatusBar bool true
    
    # Set default Finder location to home folder
    safe_defaults com.apple.finder NewWindowTarget string "PfLo"
    safe_defaults com.apple.finder NewWindowTargetPath string "file://${HOME}/"
    
    # Search current folder by default
    safe_defaults com.apple.finder FXDefaultSearchScope string "SCcf"
    
    # Disable warning when changing file extension
    safe_defaults com.apple.finder FXEnableExtensionChangeWarning bool false
    
    # Enable spring loading for directories
    safe_defaults NSGlobalDomain com.apple.springing.enabled bool true
    
    # Remove delay for spring loading
    safe_defaults NSGlobalDomain com.apple.springing.delay float 0
    
    # Avoid creating .DS_Store files on network or USB volumes
    safe_defaults com.apple.desktopservices DSDontWriteNetworkStores bool true
    safe_defaults com.apple.desktopservices DSDontWriteUSBStores bool true
    
    ###################
    # Dock Settings
    ###################
    log "Configuring Dock settings..."
    
    # Enable Dock auto-hide
    safe_defaults com.apple.dock autohide bool true
    
    # Remove auto-hide delay
    safe_defaults com.apple.dock autohide-delay float 0
    
    # Make animation faster
    safe_defaults com.apple.dock autohide-time-modifier float 0.5
    
    # Set Dock icon size
    safe_defaults com.apple.dock tilesize int 48
    
    # Enable magnification
    safe_defaults com.apple.dock magnification bool true
    
    # Set magnification size
    safe_defaults com.apple.dock largesize int 64
    
    # Minimize windows using scale effect
    safe_defaults com.apple.dock mineffect string "scale"
    
    # Don't show recent applications in Dock
    safe_defaults com.apple.dock show-recents bool false
    
    # Show indicator lights for open applications
    safe_defaults com.apple.dock show-process-indicators bool true
    
    ###################
    # Screenshots
    ###################
    log "Configuring screenshot settings..."
    
    # Create Screenshots folder if it doesn't exist
    mkdir -p "${HOME}/Screenshots"
    
    # Save screenshots to custom folder
    safe_defaults com.apple.screencapture location string "${HOME}/Screenshots"
    
    # Save screenshots in PNG format
    safe_defaults com.apple.screencapture type string "png"
    
    # Disable shadow in screenshots
    safe_defaults com.apple.screencapture disable-shadow bool true
    
    ###################
    # General UI/UX
    ###################
    log "Configuring general UI/UX settings..."
    
    # Expand save panel by default
    safe_defaults NSGlobalDomain NSNavPanelExpandedStateForSaveMode bool true
    safe_defaults NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 bool true
    
    # Expand print panel by default
    safe_defaults NSGlobalDomain PMPrintingExpandedStateForPrint bool true
    safe_defaults NSGlobalDomain PMPrintingExpandedStateForPrint2 bool true
    
    # Disable the "Are you sure you want to open this application?" dialog
    safe_defaults com.apple.LaunchServices LSQuarantine bool false
    
    # Enable full keyboard access for all controls
    safe_defaults NSGlobalDomain AppleKeyboardUIMode int 3
    
    # Enable subpixel font rendering on non-Apple LCDs (may not work on newer macOS)
    safe_defaults NSGlobalDomain AppleFontSmoothing int 2 || true
    
    # Disable auto-correct
    safe_defaults NSGlobalDomain NSAutomaticSpellingCorrectionEnabled bool false
    
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