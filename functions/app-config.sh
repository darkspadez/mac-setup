#!/bin/bash

#############################################################
# App Replacements and Default Applications Configuration
#############################################################

configure_app_replacements() {
    log "Configuring application replacements..."
    
    # Configure Raycast to replace Spotlight
    configure_raycast() {
        log "Configuring Raycast to replace Spotlight..."
        
        if [[ "$DRY_RUN" == true ]]; then
            log "[DRY-RUN] Would configure Raycast"
            return 0
        fi
        
        # Disable Spotlight keyboard shortcut
        # This disables Cmd+Space for Spotlight
        defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "<dict><key>enabled</key><false/></dict>"
        defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 65 "<dict><key>enabled</key><false/></dict>"
        
        # Kill SystemUIServer to apply changes
        killall SystemUIServer 2>/dev/null || true
        
        # Open Raycast to configure it
        if [[ -d "/Applications/Raycast.app" ]]; then
            open -a Raycast
            
            # Use AppleScript to try setting up the hotkey
            osascript << 'EOF' 2>/dev/null || true
tell application "System Events"
    delay 2
    tell application "Raycast" to activate
end tell
EOF
            
            info "Please set Raycast hotkey to Cmd+Space in Raycast preferences"
            info "You can also import your Raycast settings if you have them"
        else
            warning "Raycast not found. Please install it first."
        fi
        
        success "Spotlight disabled for Raycast"
    }
    
    # Configure Warp as default terminal
    configure_warp() {
        log "Configuring Warp as default terminal..."
        
        if [[ "$DRY_RUN" == true ]]; then
            log "[DRY-RUN] Would configure Warp as default terminal"
            return 0
        fi
        
        if [[ -d "/Applications/Warp.app" ]]; then
            # Set Warp as default terminal for .command files
            defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
                '{"LSHandlerContentType":"public.unix-executable","LSHandlerRoleAll":"dev.warp.Warp-Stable";}'
            
            # Set Warp as default for terminal URLs
            defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
                '{"LSHandlerURLScheme":"terminal","LSHandlerRoleAll":"dev.warp.Warp-Stable";}'
            
            # Rebuild Launch Services database
            /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
                -kill -r -domain local -domain system -domain user
            
            success "Warp configured as default terminal"
        else
            warning "Warp not found. Please install it first."
        fi
    }
    
    # Execute configurations
    configure_raycast
    configure_warp
    
    success "App replacements configured"
}

set_default_apps() {
    log "Setting default applications..."
    
    # Set Perplexity Comet as default browser
    set_default_browser() {
        log "Setting Perplexity Comet as default browser..."
        
        if [[ "$DRY_RUN" == true ]]; then
            log "[DRY-RUN] Would set Perplexity Comet as default browser"
            return 0
        fi
        
        # Check if Comet is installed
        if [[ ! -d "/Applications/Comet.app" ]]; then
            warning "Perplexity Comet not found. Skipping default browser configuration."
            return 1
        fi
        
        # Install macdefaultbrowser tool if not present
        if ! command_exists macdefaultbrowser; then
            log "Installing macdefaultbrowser tool..."
            brew install https://raw.githubusercontent.com/twardoch/macdefaultbrowser/main/macdefaultbrowser.rb --build-from-source
        fi
        
        # Set Comet as default browser
        if command_exists macdefaultbrowser; then
            macdefaultbrowser comet
            success "Perplexity Comet set as default browser"
        else
            warning "Could not set default browser. Please set it manually in System Settings."
        fi
    }
    
    # Set VS Code Insiders as default text editor
    set_default_editor() {
        log "Setting VS Code Insiders as default text editor..."
        
        if [[ "$DRY_RUN" == true ]]; then
            log "[DRY-RUN] Would set VS Code Insiders as default editor"
            return 0
        fi
        
        # Install VS Code Insiders command line tools
        if [[ -d "/Applications/Visual Studio Code - Insiders.app" ]]; then
            # Create code-insiders symlink if it doesn't exist
            if [[ ! -f "/usr/local/bin/code-insiders" ]]; then
                ln -sf "/Applications/Visual Studio Code - Insiders.app/Contents/Resources/app/bin/code" /usr/local/bin/code-insiders
            fi
            
            # Set as default for various file types
            declare -a file_extensions=(
                "txt" "md" "markdown" "json" "js" "ts" "jsx" "tsx"
                "html" "css" "scss" "py" "rb" "go" "rs" "swift"
                "c" "cpp" "h" "hpp" "java" "php" "sh" "bash" "zsh"
                "yml" "yaml" "toml" "ini" "conf" "env"
            )
            
            for ext in "${file_extensions[@]}"; do
                duti -s com.microsoft.VSCodeInsiders .$ext all 2>/dev/null || true
            done
            
            success "VS Code Insiders set as default text editor"
        else
            warning "VS Code Insiders not found. Please install it first."
        fi
    }
    
    # Execute configurations
    set_default_browser
    set_default_editor
    
    success "Default applications configured"
}