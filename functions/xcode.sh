#!/bin/bash

#############################################################
# Xcode Command Line Tools Installation
#############################################################

install_xcode_tools() {
    log "Checking Xcode Command Line Tools..."
    
    # Check if Xcode CLI tools are already installed
    if xcode-select -p &> /dev/null; then
        success "Xcode Command Line Tools already installed"
        return 0
    fi
    
    log "Installing Xcode Command Line Tools..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] Would install Xcode Command Line Tools"
        return 0
    fi
    
    # Create placeholder file to track installation
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    
    # Find the CLI Tools package
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^:]*: //')
    
    if [[ -n "$PROD" ]]; then
        softwareupdate -i "$PROD" --verbose
    else
        # Fallback to manual trigger
        xcode-select --install
        
        # Wait for installation to complete
        echo "Please complete the Xcode CLI Tools installation in the popup window..."
        echo "Press Enter when installation is complete..."
        read -r
    fi
    
    # Remove placeholder
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    
    # Accept license
    sudo xcodebuild -license accept 2>/dev/null || true
    
    success "Xcode Command Line Tools installed successfully"
    
    # Install Rosetta 2 on Apple Silicon Macs
    if is_apple_silicon; then
        install_rosetta2
    fi
}

#############################################################
# Rosetta 2 Installation (Apple Silicon only)
#############################################################

install_rosetta2() {
    log "Checking Rosetta 2 installation status..."
    
    # Check if Rosetta 2 is already installed
    if arch -x86_64 /usr/bin/true 2>/dev/null; then
        success "Rosetta 2 already installed"
        return 0
    fi
    
    log "Installing Rosetta 2 for x86_64 compatibility..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] Would install Rosetta 2"
        return 0
    fi
    
    # Install Rosetta 2 silently
    if softwareupdate --install-rosetta --agree-to-license 2>&1 | tee -a "$LOG_FILE"; then
        success "Rosetta 2 installed successfully"
    else
        warning "Failed to install Rosetta 2"
        warning "Some x86_64 applications may not work without Rosetta 2"
        warning "You can install it manually later with:"
        warning "  softwareupdate --install-rosetta --agree-to-license"
        # Don't fail the script, continue execution
        return 1
    fi
}