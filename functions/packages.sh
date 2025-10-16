#!/bin/bash

#############################################################
# Package Installation Functions
#############################################################

install_brewfile_packages() {
    log "Installing packages from Brewfile..."
    
    # Check if Brewfile exists
    if [[ ! -f "Brewfile" ]]; then
        error "Brewfile not found in current directory"
        return 1
    fi
    
    
    # Install all packages from Brewfile
    log "Running brew bundle install..."
    if [[ "$DRY_RUN" == false ]]; then
        brew bundle install --verbose
        success "All packages from Brewfile installed"
    else
        log "[DRY-RUN] Would run: brew bundle install"
    fi
    
    # Install special packages that might need specific handling
    log "Installing special packages..."
    
    # Install oh-my-zsh (not via brew, but we handle it here)
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log "Installing Oh My Zsh..."
        if [[ "$DRY_RUN" == false ]]; then
            sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        else
            log "[DRY-RUN] Would install Oh My Zsh"
        fi
        success "Oh My Zsh installed"
    else
        success "Oh My Zsh already installed"
    fi
    
    # Install coderabbit if available
    if ! brew_installed "coderabbit"; then
        log "Attempting to install CodeRabbit..."
        if brew search coderabbit &>/dev/null; then
            run_command "brew install coderabbit"
        else
            warning "CodeRabbit not found in Homebrew. You may need to install it manually."
        fi
    fi
    
    success "All Homebrew packages installed"
}

install_native_apps() {
    log "Installing native applications..."
    
    # Perplexity Comet Browser - installed manually as it's not in Homebrew
    if [[ ! -d "/Applications/Comet.app" ]]; then
        log "Downloading Perplexity Comet Browser..."
        if [[ "$DRY_RUN" == false ]]; then
            # Download Perplexity Comet browser for macOS
            # Using the correct URL for Comet browser (not the client)
            local download_url="https://www.perplexity.ai/rest/browser/download?channel=stable&platform=mac_arm64"
            curl -L "$download_url" -o /tmp/perplexity-comet.dmg
            
            # Mount the DMG
            hdiutil attach /tmp/perplexity-comet.dmg -nobrowse -quiet
            
            # Find the mounted volume (it might vary)
            local volume_path
            volume_path=$(find /Volumes -maxdepth 1 -name "*Comet*" -o -name "Perplexity*" -type d | head -n 1)
            
            if [[ -n "$volume_path" ]]; then
                # Copy the app to Applications (DMG contains Comet.app)
                cp -R "$volume_path/Comet.app" /Applications/
                # Unmount the DMG
                hdiutil detach "$volume_path" -quiet
                rm /tmp/perplexity-comet.dmg
                success "Perplexity Comet Browser installed"
            else
                error "Could not find Comet.app in mounted DMG"
                rm /tmp/perplexity-comet.dmg
                return 1
            fi
        else
            log "[DRY-RUN] Would install Perplexity Comet Browser"
        fi
    else
        success "Perplexity Comet Browser already installed"
    fi
    
    # boringNotch - macOS notch utility
    if [[ ! -d "/Applications/boringNotch.app" ]]; then
        log "Downloading boringNotch..."
        if [[ "$DRY_RUN" == false ]]; then
            local boring_url="https://github.com/TheBoredTeam/boring.notch/releases/latest/download/boringNotch.dmg"
            curl -L "$boring_url" -o /tmp/boringNotch.dmg
            
            # Mount the DMG
            hdiutil attach /tmp/boringNotch.dmg -nobrowse -quiet
            
            # Find the mounted volume
            local volume_path
            volume_path=$(find /Volumes -maxdepth 1 -name "*boring*" -o -name "*Notch*" -type d | head -n 1)
            
            if [[ -n "$volume_path" ]]; then
                # Copy the app to Applications
                cp -R "$volume_path"/*.app /Applications/ 2>/dev/null || cp -R "$volume_path/boringNotch.app" /Applications/
                # Unmount the DMG
                hdiutil detach "$volume_path" -quiet
                rm /tmp/boringNotch.dmg
                success "boringNotch installed"
            else
                error "Could not find boringNotch.app in mounted DMG"
                rm /tmp/boringNotch.dmg
                return 1
            fi
        else
            log "[DRY-RUN] Would install boringNotch"
        fi
    else
        success "boringNotch already installed"
    fi
    
    # Synergy - Keyboard and mouse sharing
    if [[ ! -d "/Applications/Synergy.app" ]]; then
        log "Installing Synergy..."
        if [[ "$DRY_RUN" == false ]]; then
            # Synergy requires manual download due to authentication
            log "========================================="
            log "Synergy Installation"
            log "========================================="
            log "Please download Synergy from: https://symless.com/synergy/download"
            log ""
            log "After downloading, the file should be in ~/Downloads/"
            log "Example: ~/Downloads/synergy-3.3.1-macos-arm64.dmg"
            echo ""
            read -p "Have you downloaded Synergy? (yes/no/skip): " synergy_choice
            
            case "${synergy_choice,,}" in
                yes|y)
                    # Look for Synergy DMG in Downloads folder
                    local synergy_dmg
                    synergy_dmg=$(find "$HOME/Downloads" -name "synergy*.dmg" -type f | head -n 1)
                    
                    if [[ -z "$synergy_dmg" ]]; then
                        error "Could not find Synergy DMG in ~/Downloads/"
                        error "Please download it from https://symless.com/synergy/download"
                        return 1
                    fi
                    
                    log "Found Synergy DMG: $synergy_dmg"
                    log "Installing Synergy..."
                    
                    # Mount the DMG
                    hdiutil attach "$synergy_dmg" -nobrowse -quiet
                    
                    # Find the mounted volume
                    local volume_path
                    volume_path=$(find /Volumes -maxdepth 1 -name "*Synergy*" -type d | head -n 1)
                    
                    if [[ -n "$volume_path" ]]; then
                        # Copy the app to Applications
                        cp -R "$volume_path"/*.app /Applications/ 2>/dev/null || cp -R "$volume_path/Synergy.app" /Applications/
                        # Unmount the DMG
                        hdiutil detach "$volume_path" -quiet
                        success "Synergy installed"
                    else
                        error "Could not find Synergy.app in mounted DMG"
                        return 1
                    fi
                    ;;
                no|n)
                    error "Synergy installation cancelled. Please download it first."
                    return 1
                    ;;
                skip|s|"")
                    warning "Skipping Synergy installation. You can install it manually later."
                    return 0
                    ;;
                *)
                    error "Invalid choice. Please answer yes, no, or skip."
                    return 1
                    ;;
            esac
        else
            log "[DRY-RUN] Would install Synergy"
        fi
    else
        success "Synergy already installed"
    fi
}

install_bun_packages() {
    log "Installing Bun global packages..."
    
    # Ensure bun is installed
    if ! command_exists bun; then
        error "Bun is not installed. Please install it first."
        return 1
    fi
    
    # Global packages to install
    declare -a bun_packages=(
        "@cloudflare/claude-code"
        "@openai/codex"
        "@google/gemini-cli"
        "ccusage"
        "@githubnext/copilot-cli"
        "@kilocode/cli@alpha"
    )
    
    for package in "${bun_packages[@]}"; do
        log "Installing $package..."
        if [[ "$DRY_RUN" == false ]]; then
            if bun pm ls -g 2>/dev/null | grep -q "$package"; then
                success "$package already installed"
            else
                run_command "bun add -g $package"
                success "$package installed"
            fi
        else
            log "[DRY-RUN] Would install $package"
        fi
    done
    
    success "All Bun global packages installed"
}