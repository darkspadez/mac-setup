#!/bin/bash

#############################################################
# Homebrew Installation and Setup
#############################################################

install_homebrew() {
    log "Checking Homebrew installation..."
    
    if command_exists brew; then
        success "Homebrew already installed"
        log "Updating Homebrew..."
        run_command "brew update"
        return 0
    fi
    
    log "Installing Homebrew..."
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] Would install Homebrew"
        return 0
    fi
    
    # Install Homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        
        # Add to current shell session
        export PATH="/opt/homebrew/bin:$PATH"
    fi
    
    # For Intel Macs
    if [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
        export PATH="/usr/local/bin:$PATH"
    fi
    
    # Verify installation
    if command_exists brew; then
        success "Homebrew installed successfully"
        brew --version
    else
        error "Failed to install Homebrew"
        exit 1
    fi
}

install_mas_cli() {
    log "Installing Mac App Store CLI (mas)..."
    
    if brew_installed "mas"; then
        success "mas already installed"
        return 0
    fi
    
    run_command "brew install mas"
    success "mas installed successfully"
}