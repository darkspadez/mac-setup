# Mac Setup Automation Script

A comprehensive automation script for setting up a fresh macOS installation with development tools, productivity apps, and custom system configurations.

## Features

- 🚀 **Automated Installation**: One command to set up your entire development environment
- 🔧 **Modular Design**: Run specific components independently
- 🔄 **Idempotent**: Safe to run multiple times without duplicating installations
- 📝 **Comprehensive Logging**: Detailed logs of all operations
- 🧪 **Dry-Run Mode**: Test the script without making actual changes
- ⚡ **Modern Tools**: Replaces traditional Unix tools with modern alternatives
- 🔮 **Future-Proof**: Compatible with macOS 15.x through latest beta versions

## Prerequisites

- macOS 15.x or later (tested on macOS Sequoia 15.1+)
- Compatible with newer macOS versions including beta releases
- Administrator privileges
- Internet connection
- Apple ID (for Mac App Store apps)

> **Note for Beta Users**: While this script is designed to work with the latest macOS beta versions (including macOS 26.x), some settings may behave differently on untested versions. The script includes robust error handling to gracefully handle incompatibilities.

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/yourusername/mac-setup.git
cd mac-setup
```

2. Make the script executable:
```bash
chmod +x setup-mac.sh
```

3. Run the setup script:
```bash
./setup-mac.sh
```

## Usage Options

### Full Installation
```bash
./setup-mac.sh
```

### Dry-Run Mode
Test the script without making any changes:
```bash
./setup-mac.sh --dry-run
```

### Run Specific Components
Install only selected components:
```bash
./setup-mac.sh --only homebrew,settings,shell
```

Available components:
- `xcode` - Xcode Command Line Tools
- `homebrew` - Homebrew package manager
- `settings` - macOS system preferences
- `mas` - Mac App Store apps
- `brew-packages` - Homebrew packages and casks
- `native-apps` - Native applications (Perplexity, Chrome)
- `shell` - Shell environment (Oh-My-Zsh, Powerlevel10k)
- `dotfiles` - Configuration files (.zshrc, .gitconfig)
- `bun-packages` - Bun global packages
- `app-replacements` - App replacements (Raycast, Warp)
- `defaults` - Default applications

## What Gets Installed

### System Configuration
- ✅ iCloud Drive for Desktop & Documents
- ✅ Hidden files visible in Finder
- ✅ File extensions shown
- ✅ Auto-hiding Dock
- ✅ Disabled desktop widgets

### Development Tools
- **Languages**: Node.js, Bun, PHP 8.4, Go, Rust
- **Version Control**: Git, GitHub CLI, GitKraken, Chezmoi
- **Editors**: VS Code Insiders, Claude
- **Containers**: Docker
- **API Testing**: Postman

### Terminal & Shell
- **Terminal**: Warp (replaces default Terminal)
- **Shell**: Zsh with Oh-My-Zsh
- **Theme**: Powerlevel10k
- **Modern CLI Tools**:
  - `eza` → replaces `ls`
  - `bat` → replaces `cat`
  - `fd` → replaces `find`
  - `ripgrep` → replaces `grep`
  - `fzf` → fuzzy finder

### Productivity Apps
- **Launcher**: Raycast (replaces Spotlight)
- **Password Manager**: 1Password
- **VPN**: Tailscale, Proton VPN
- **Email**: Proton Mail
- **Cloud Storage**: Filen
- **Screenshot**: Shotrr
- **Communication**: Discord

### Mac App Store Apps
- Infuse 7 - Media player
- Magnet - Window management
- Unsplash Wallpapers - Dynamic wallpapers

### Browsers
- Perplexity Comet (set as default)
- Google Chrome

### Fonts
- Fira Code
- JetBrains Mono

### Bun Global Packages
- `@cloudflare/claude-code` - Claude CLI
- `@openai/codex` - OpenAI Codex
- `@google/gemini-cli` - Google Gemini CLI
- `ccusage` - Code complexity analyzer
- `@githubnext/copilot-cli` - GitHub Copilot CLI
- `@kilocode/cli@alpha` - Kilocode CLI

## Shell Aliases

The script configures useful aliases in `.zshrc`:

### File Operations
```bash
ls    # eza with icons
ll    # long format with icons
la    # show all including hidden
lt    # tree view with icons
```

### Package Managers
```bash
npm   # → bun
npx   # → bunx
yarn  # → bun
pnpm  # → bun
```

### Git Shortcuts
```bash
gs    # git status
ga    # git add
gc    # git commit
gco   # git checkout
gb    # git branch
gp    # git push
gl    # git log (formatted)
```

### Docker Shortcuts
```bash
dps   # docker ps
dpsa  # docker ps -a
di    # docker images
dex   # docker exec -it
dlog  # docker logs -f
```

## Post-Installation Steps

After running the script, complete these manual steps:

### 1. Sign In to Applications
- 1Password
- Tailscale
- Proton Mail & VPN
- Discord
- Filen
- Postman

### 2. Configure Raycast
- Open Raycast preferences
- Set hotkey to `Cmd+Space`
- Import your settings/extensions
- Configure workflows

### 3. VS Code Insiders Setup
- Sign in with GitHub for settings sync
- Install your preferred extensions

### 4. Generate SSH Keys
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

### 5. Update Git Configuration
Edit `~/.gitconfig` with your information:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 6. Restart Your Mac
Some settings require a restart to take full effect.

## Customization

### Modifying Package Lists

Edit the package arrays in `functions/packages.sh`:
```bash
declare -a languages=(
    "node"
    "bun"
    "python3"  # Add new language
)
```

### Adding Custom Aliases

Edit `functions/shell-config.sh` to add your own aliases in the `.zshrc` configuration.

### Changing System Preferences

Modify `functions/macos-settings.sh` to adjust macOS configurations.

## Troubleshooting

### Script Fails to Run
- Ensure you have administrator privileges
- Check internet connection
- Review the log file in `logs/` directory

### Homebrew Installation Issues
```bash
# Manually install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then re-run specific components
./setup-mac.sh --only brew-packages
```

### Raycast Not Replacing Spotlight
1. Open System Settings → Keyboard → Keyboard Shortcuts
2. Disable Spotlight shortcuts manually
3. Open Raycast and set `Cmd+Space` as hotkey

### Default Browser Not Changing
```bash
# Install and use defaultbrowser tool
brew install defaultbrowser
defaultbrowser perplexity
```

## Logs

All operations are logged to `logs/setup-YYYY-MM-DD-HHMMSS.log`. Review this file if you encounter any issues.

## Contributing

Feel free to submit issues and pull requests to improve this script.

## License

MIT License - feel free to use and modify as needed.

## Version Compatibility

### Tested Versions
- ✅ macOS Sequoia 15.1
- ✅ macOS Sequoia 15.x series

### Supported Versions
- macOS 15.x and later (including beta versions)
- The script includes version detection and will inform you if you're running on an untested version
- Newer macOS versions (16.x, 26.x, etc.) should work with graceful degradation for unsupported settings

### Known Limitations on Beta Versions

When running on beta or newer untested macOS versions, you may encounter:

1. **System Settings Changes**: Some `defaults` commands may not work if Apple has changed domain names or keys
2. **Permission Changes**: Beta versions may have stricter security requirements
3. **Deprecated Settings**: Some settings may no longer be available or may use different mechanisms

The script handles these gracefully by:
- Logging warnings for failed settings (without stopping execution)
- Continuing with installation even if some configurations fail
- Providing clear error messages about what didn't work

### Troubleshooting for Newer macOS Versions

#### Settings Not Applying
If some settings don't apply on your macOS version:

```bash
# Run in dry-run mode first to see what would happen
./setup-mac.sh --dry-run

# Check the log file for warnings about failed settings
tail -f logs/setup-*.log | grep "Failed to set"
```

#### Version-Specific Issues

**For macOS 16.x and later:**
- Some Finder settings may use different domain names
- Widget settings might have moved to a different preference pane
- Check System Settings manually for settings that didn't apply

**For beta versions:**
- Security settings may require manual approval in System Settings
- Some automation features may be disabled by default
- You may need to grant additional permissions

#### Getting Help

If you encounter issues on a specific macOS version:

1. Check the log file in `logs/` directory
2. Look for "Failed to set" warnings
3. Manually verify which settings didn't apply
4. Settings can be manually configured in System Settings if needed

The core functionality (Homebrew, packages, applications) should work regardless of macOS version, as these rely on package managers rather than system settings.

## Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/) for the amazing shell framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) for the beautiful theme
- [Homebrew](https://brew.sh/) for simplifying macOS package management
- All the amazing open-source tool authors

---

**Note**: This script is designed for macOS 15.x and later. While it includes support for newer versions and betas, some features may work differently on untested versions. The script will inform you if you're running on a newer version and handle incompatibilities gracefully. Always review the script and run in `--dry-run` mode first when using on beta versions.