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
    # Trackpad Settings
    ###################
    log "Configuring trackpad settings..."
    
    # Enable tap to click for this user and for the login screen
    safe_defaults com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking bool true
    safe_defaults NSGlobalDomain com.apple.mouse.tapBehavior int 1
    
    # Disable two-finger secondary click (only use corner click)
    safe_defaults com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick bool false
    safe_defaults com.apple.AppleMultitouchTrackpad TrackpadRightClick bool false
    
    # Set trackpad corner clicking: bottom right = right click
    # TrackpadCornerSecondaryClick: 0 = off, 1 = bottom right, 2 = bottom left
    safe_defaults com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick int 1
    safe_defaults com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick int 1
    
    # Disable three finger drag (basic trackpad mode)
    safe_defaults com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag bool false
    safe_defaults com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag bool false
    
    # Set tracking speed (0 = slow, 3 = fast)
    safe_defaults NSGlobalDomain com.apple.trackpad.scaling float 1
    
    # Disable force click and haptic feedback (basic mode)
    safe_defaults NSGlobalDomain com.apple.trackpad.forceClick bool false
    safe_defaults com.apple.AppleMultitouchTrackpad ActuateDetents bool false
    safe_defaults com.apple.AppleMultitouchTrackpad ForceSuppressed bool true
    
    # Enable natural scrolling (swipe up = content moves up, like on phone)
    safe_defaults NSGlobalDomain com.apple.swipescrolldirection bool true
    
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
    
    # Allow apps downloaded from anywhere (disables Gatekeeper for unidentified developers)
    log "Disabling Gatekeeper to allow apps from anywhere..."
    sudo spctl --master-disable 2>/dev/null || warning "Failed to disable Gatekeeper (may require manual sudo access)"
    
    # Disable quarantine attribute on downloaded files (removes 'downloaded from internet' warnings)
    safe_defaults com.apple.LaunchServices LSQuarantine bool false
    
    # Reduce security dialog frequency for opening apps
    safe_defaults com.apple.security.GKAutoRearm bool false || true
    
    ###################
    # Kernel Extensions (KEXTs)
    ###################
    log "Configuring kernel extension settings..."
    
    # Note: Apple Silicon Macs (M1/M2/M3) require user approval for kernel extensions in Recovery Mode
    # Intel Macs can have reduced security for KEXTs, but it still requires user interaction
    
    # Reduce kernel extension blocking (requires SIP disabled on Apple Silicon)
    # This setting is primarily for Intel Macs and may not work on Apple Silicon
    sudo spctl --kext-consent 2>/dev/null || true
    
    # Inform user about manual steps needed for kernel extensions
    info "──────────────────────────────────────────────────────────────"
    info "KERNEL EXTENSION NOTICE:"
    info "Some Homebrew apps require kernel extensions (KEXTs)."
    info ""
    info "On Intel Macs:"
    info "  • Go to System Settings > Privacy & Security"
    info "  • When apps request kernel extensions, click 'Allow'"
    info "  • You may need to restart after allowing KEXTs"
    info ""
    info "On Apple Silicon Macs (M1/M2/M3):"
    info "  • Restart your Mac into Recovery Mode (hold power button)"
    info "  • Go to Utilities > Startup Security Utility"
    info "  • Select your boot disk and click Security Policy"
    info "  • Choose 'Reduced Security' and enable 'Allow kernel extensions'"
    info "  • Restart and approve any kernel extension prompts in System Settings"
    info "──────────────────────────────────────────────────────────────"
    
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