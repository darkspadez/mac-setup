# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive macOS automation framework for setting up a development environment on macOS 15.x+. It follows a modular, idempotent design with support for both Apple Silicon (arm64) and Intel (x86_64) architectures.

## Common Commands

### Full Setup
```bash
./setup-mac.sh                              # Complete installation
./setup-mac.sh --dry-run                    # Preview mode (shows what would be done)
./setup-mac.sh --only homebrew,settings     # Run specific components only
./setup-mac.sh --help                       # Show available options
```

### Available Components for `--only` flag
- `xcode` - Xcode Command Line Tools & Rosetta 2
- `homebrew` - Homebrew package manager
- `settings` - macOS system preferences via defaults write
- `brew-packages` - Install packages from Brewfile
- `native-apps` - Manual DMG installations (Perplexity, boringNotch, Synergy)
- `shell` - Oh My Zsh and Powerlevel10k setup
- `dotfiles` - Generate .zshrc and .gitconfig
- `bun-packages` - Global Bun packages (AI/LLM tools)
- `app-replacements` - Configure Raycast to replace Spotlight
- `defaults` - Set default applications

### Testing Changes
```bash
# Always test with dry-run first
./setup-mac.sh --dry-run --only <component>

# Check logs for errors
tail -f logs/setup-*.log

# Validate shell scripts
shellcheck setup-mac.sh functions/*.sh
```

## Architecture and Code Flow

### Entry Point Flow
```
setup-mac.sh
├── Parse arguments (--dry-run, --only, --help)
├── System validation
│   ├── macOS version check (15.x+)
│   ├── Architecture detection (arm64/x86_64)
│   ├── Admin privileges check
│   └── Internet connectivity check
├── Source all function files from functions/
├── Execute components in order (if selected)
└── Show post-installation instructions
```

### Component Dependencies
1. **Xcode CLT** must be installed first (prerequisite for Homebrew)
2. **Homebrew** required before brew-packages
3. **Shell setup** should run before dotfiles generation
4. Most other components are independent

### Key Architectural Patterns

**Modular Functions**: Each script in `functions/` is self-contained and sources independently:
```bash
source "$(dirname "$0")/functions/xcode.sh"
```

**Idempotent Checks**: Every installation checks existence first:
```bash
if ! command -v brew &>/dev/null; then
    # Install Homebrew
fi
```

**Architecture Awareness**: Code branches based on system architecture:
```bash
if [[ "$ARCH" == "arm64" ]]; then
    # Apple Silicon specific code
else
    # Intel specific code
fi
```

**Safe Defaults Writing**: System settings use error handling wrapper:
```bash
safe_defaults() {
    defaults write "$@" 2>/dev/null || true
}
```

**Dry Run Support**: All destructive operations check `DRY_RUN` flag:
```bash
if [[ "$DRY_RUN" == "true" ]]; then
    info "Would install: $package"
else
    brew install "$package"
fi
```

## Important File Locations

### Core Files
- `setup-mac.sh` - Main orchestrator with utility functions and component execution
- `Brewfile` - Package manifest (118 lines) with all Homebrew formulae, casks, and fonts
- `functions/macos-settings.sh` - System preferences (247 lines of defaults commands)
- `functions/shell-config.sh` - Generates .zshrc with 40+ aliases and shell configuration

### Generated Files
- `logs/setup-YYYY-MM-DD-HHMMSS.log` - Execution logs with timestamps
- `~/.zshrc` - Generated shell configuration with Oh My Zsh
- `~/.gitconfig` - Git configuration with aliases and VS Code integration

## Critical Implementation Details

### Architecture-Specific Paths
- Apple Silicon Homebrew: `/opt/homebrew`
- Intel Homebrew: `/usr/local`
- Always use `$(brew --prefix)` for portability

### Version Compatibility
- Supports macOS 15.x and later (including beta versions like 26.1)
- Uses `sw_vers -productVersion` for detection
- Graceful degradation for newer versions

### Error Handling
- Scripts use `set -euo pipefail` for strict error handling
- All risky operations wrapped in error handlers
- Logging captures both stdout and stderr

### Native App Installation Pattern
DMG downloads follow this structure:
```bash
1. Download DMG to temporary location
2. Mount DMG with hdiutil
3. Copy .app to /Applications
4. Unmount DMG
5. Clean up downloaded file
```

### Shell Alias Strategy
Modern CLI replacements defined in .zshrc:
- `ls` → `eza` (with icons and git status)
- `cat` → `bat` (syntax highlighting)
- `find` → `fd` (faster, simpler syntax)
- `grep` → `rg` (ripgrep)
- `cd` → `z` (smart directory jumping)

## Development Notes

### Adding New Packages
1. Add to `Brewfile` in appropriate section
2. Run `./setup-mac.sh --only brew-packages` to test

### Adding System Settings
1. Edit `functions/macos-settings.sh`
2. Use `safe_defaults()` wrapper for new settings
3. Test with `./setup-mac.sh --dry-run --only settings`

### Adding New Components
1. Create new function in appropriate file under `functions/`
2. Add component name to help text in `setup-mac.sh`
3. Add execution block in main script
4. Update `should_run_component()` logic if needed

### Debugging
- Enable verbose logging: Add `-x` to shebang line
- Check component logs: `grep "ERROR\|WARN" logs/*.log`
- Test individual functions: Source file and call function directly

## Common Gotchas

1. **Rosetta 2**: Automatically installed on Apple Silicon but some apps may still require manual configuration
2. **Gatekeeper**: Some downloaded apps need manual approval in System Settings → Privacy & Security
3. **Shell Changes**: New shell configuration requires terminal restart or `source ~/.zshrc`
4. **PATH Updates**: Homebrew path must be in shell config before other tools work
5. **Oh My Zsh**: Installed via curl, not Homebrew, to avoid permission issues