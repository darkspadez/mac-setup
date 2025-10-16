#!/bin/bash

#############################################################
# Mac Setup Automation Script for macOS 15.x and later
# This script automates the setup of a fresh Mac installation
# with development tools, apps, and system configurations
#
# Tested on: macOS Sequoia 15.1+
# Compatible with: macOS 15.x through latest beta versions
#############################################################

set -euo pipefail  # Exit on error, undefined variables, and pipe failures

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/setup-$(date +%Y-%m-%d-%H%M%S).log"
DRY_RUN=false
COMPONENTS_TO_RUN=()

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

#############################################################
# Utility Functions
#############################################################

log() {
    local message="$1"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[${timestamp}]${NC} $message" | tee -a "$LOG_FILE"
}

success() {
    local message="$1"
    echo -e "${GREEN}✅${NC} $message" | tee -a "$LOG_FILE"
}

error() {
    local message="$1"
    echo -e "${RED}❌ ERROR:${NC} $message" | tee -a "$LOG_FILE"
}

warning() {
    local message="$1"
    echo -e "${YELLOW}⚠️  WARNING:${NC} $message" | tee -a "$LOG_FILE"
}

info() {
    local message="$1"
    echo -e "${BLUE}ℹ️${NC}  $message" | tee -a "$LOG_FILE"
}

# Check if running in dry-run mode
run_command() {
    local cmd="$1"
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY-RUN] Would execute: $cmd"
    else
        log "Executing: $cmd"
        eval "$cmd" 2>&1 | tee -a "$LOG_FILE"
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if a package is installed via Homebrew
brew_installed() {
    if command_exists brew; then
        brew list --formula 2>/dev/null | grep -q "^$1$" || brew list --cask 2>/dev/null | grep -q "^$1$"
    else
        return 1
    fi
}

# Verify macOS version
check_macos_version() {
    local os_version
    os_version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$os_version" | cut -d. -f1)
    
    log "Current macOS version: $os_version"
    
    # Check if macOS version is 15 or higher
    if [[ "$major_version" -lt 15 ]]; then
        warning "This script is designed for macOS 15.x and later. Current version: $os_version"
        warning "Some features may not work correctly on older versions."
        read -p "Do you want to continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error "Exiting due to macOS version requirement not met"
            exit 1
        fi
    elif [[ "$major_version" -gt 15 ]]; then
        info "Running on macOS $os_version (newer than tested version 15.x)"
        info "The script should work, but some settings may need adjustment."
    else
        success "Running on supported macOS version: $os_version"
    fi
}

# Get macOS major version number
get_macos_major_version() {
    sw_vers -productVersion | cut -d. -f1
}

# Compare macOS version (returns 0 if current >= required, 1 otherwise)
version_gte() {
    local required="$1"
    local current
    current=$(get_macos_major_version)
    [[ "$current" -ge "$required" ]]
}

# Check for admin privileges
check_admin_privileges() {
    if ! sudo -n true 2>/dev/null; then
        log "Requesting administrator privileges..."
        sudo -v
        
        # Keep sudo alive
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
    success "Administrator privileges confirmed"
}

# Check internet connectivity
check_internet() {
    if ping -c 1 google.com &> /dev/null; then
        success "Internet connection verified"
    else
        error "No internet connection. Please check your network settings."
        exit 1
    fi
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                info "Running in dry-run mode - no changes will be made"
                shift
                ;;
            --only)
                IFS=',' read -ra COMPONENTS_TO_RUN <<< "$2"
                info "Running only: ${COMPONENTS_TO_RUN[*]}"
                shift 2
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help message
show_help() {
    cat << EOF
Mac Setup Automation Script

Usage: $0 [OPTIONS]

OPTIONS:
    --dry-run       Run in dry-run mode (no actual changes)
    --only <list>   Run only specified components (comma-separated)
                    Components: xcode,homebrew,settings,mas,brew-packages,
                               native-apps,shell,dotfiles,bun-packages,
                               app-replacements,defaults
    --help, -h      Show this help message

Examples:
    $0                          # Run full setup
    $0 --dry-run               # Test run without making changes
    $0 --only homebrew,settings # Run only specific components
EOF
}

#############################################################
# Source component functions
#############################################################

# Source all function files
# shellcheck source=/dev/null
for func_file in "${SCRIPT_DIR}"/functions/*.sh; do
    if [[ -f "$func_file" ]]; then
        # shellcheck source=/dev/null
        source "$func_file"
    fi
done

#############################################################
# Main Setup Flow
#############################################################

main() {
    log "======================================================"
    log "Starting Mac Setup Automation Script"
    log "======================================================"
    
    # Prerequisites
    check_macos_version
    check_admin_privileges
    check_internet
    
    # Run components
    if should_run_component "xcode"; then
        info "Installing Xcode Command Line Tools..."
        install_xcode_tools
    fi
    
    if should_run_component "homebrew"; then
        info "Setting up Homebrew..."
        install_homebrew
    fi
    
    if should_run_component "settings"; then
        info "Configuring macOS settings..."
        configure_macos_settings
    fi
    
    if should_run_component "brew-packages"; then
        info "Installing packages from Brewfile..."
        install_brewfile_packages
    fi
    
    if should_run_component "native-apps"; then
        info "Installing native applications..."
        install_native_apps
    fi
    
    if should_run_component "shell"; then
        info "Setting up shell environment..."
        setup_shell_environment
    fi
    
    if should_run_component "dotfiles"; then
        info "Configuring dotfiles..."
        configure_dotfiles
    fi
    
    if should_run_component "bun-packages"; then
        info "Installing Bun global packages..."
        install_bun_packages
    fi
    
    if should_run_component "app-replacements"; then
        info "Configuring app replacements..."
        configure_app_replacements
    fi
    
    if should_run_component "defaults"; then
        info "Setting default applications..."
        set_default_apps
    fi
    
    log "======================================================"
    success "Mac setup completed successfully!"
    log "Log file saved to: $LOG_FILE"
    log "======================================================"
    
    # Show post-installation instructions
    show_post_install_instructions
}

# Show post-installation instructions
show_post_install_instructions() {
    cat << EOF

${GREEN}Setup Complete!${NC}

${YELLOW}Manual Steps Required:${NC}

1. ${BLUE}Sign in to applications:${NC}
   - 1Password
   - Tailscale
   - Proton Mail & VPN
   - Discord
   - Filen
   - Postman

2. ${BLUE}Configure Raycast:${NC}
   - Open Raycast preferences
   - Import your settings/extensions
   - Verify Cmd+Space hotkey is working

3. ${BLUE}VS Code Insiders Setup:${NC}
   - Sign in with GitHub for settings sync
   - Install your preferred extensions

4. ${BLUE}Generate SSH Keys:${NC}
   ssh-keygen -t ed25519 -C "your.email@example.com"

5. ${BLUE}Restart your Mac${NC} to ensure all settings take effect

EOF
}

# Parse arguments and run main
parse_arguments "$@"
main

# Check if component should run
should_run_component() {
    local component="$1"
    if [[ ${#COMPONENTS_TO_RUN[@]} -eq 0 ]]; then
        return 0
    fi
    for c in "${COMPONENTS_TO_RUN[@]}"; do
        if [[ "$c" == "$component" ]]; then
            return 0
        fi
    done
    return 1
}