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
}