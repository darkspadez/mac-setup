# Contributing to Mac Setup Automation Script

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Coding Guidelines](#coding-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for all contributors.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title and description**
- **macOS version** (including whether it's Apple Silicon or Intel)
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Log files** from `logs/` directory
- **Screenshots** if applicable

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- **Clear use case** for the enhancement
- **Detailed description** of the proposed functionality
- **Examples** of how it would work
- **Potential impact** on existing functionality

### Contributing Code

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes** following our coding guidelines
4. **Test thoroughly** on both Apple Silicon and Intel if possible
5. **Commit your changes**: Use clear, descriptive commit messages
6. **Push to your fork**: `git push origin feature/your-feature-name`
7. **Submit a pull request**

## Development Setup

### Prerequisites

- macOS 15.x or later
- Git installed
- Basic knowledge of Bash scripting
- Text editor or IDE

### Initial Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/mac-setup.git
cd mac-setup

# Make scripts executable
chmod +x setup-mac.sh
chmod +x functions/*.sh

# Test in dry-run mode
./setup-mac.sh --dry-run
```

## Coding Guidelines

### Bash Script Standards

#### File Structure

- **Main script**: `setup-mac.sh` - Entry point and orchestration
- **Function files**: `functions/*.sh` - Modular components
- **Configuration**: `Brewfile` - Homebrew packages

#### Naming Conventions

- **Functions**: Use `snake_case` for function names
  ```bash
  install_xcode_tools() {
      # function body
  }
  ```

- **Variables**: Use `UPPER_CASE` for constants, `snake_case` for local variables
  ```bash
  readonly SCRIPT_DIR="/path/to/script"
  local package_name="example"
  ```

#### Code Style

- **Indentation**: 4 spaces (no tabs)
- **Line length**: Maximum 100 characters where practical
- **Comments**: Use clear, descriptive comments
  ```bash
  # Install Xcode Command Line Tools if not already present
  install_xcode_tools() {
      # Implementation
  }
  ```

- **Error handling**: Always check command exit codes
  ```bash
  if command -v brew &>/dev/null; then
      log_success "Homebrew is installed"
  else
      log_error "Homebrew not found"
      return 1
  fi
  ```

#### Best Practices

1. **Idempotency**: Scripts should be safe to run multiple times
   ```bash
   # Check before installing
   if command -v package &>/dev/null; then
       log_skip "Package already installed"
       return 0
   fi
   ```

2. **Logging**: Use consistent logging functions
   ```bash
   log_info "Starting installation..."
   log_success "Installation completed"
   log_warning "This might take a while"
   log_error "Installation failed"
   ```

3. **Architecture awareness**: Check for Apple Silicon vs Intel
   ```bash
   if is_apple_silicon; then
       # Apple Silicon specific code
   else
       # Intel specific code
   fi
   ```

4. **Dry-run support**: Respect the `DRY_RUN` flag
   ```bash
   if [[ "$DRY_RUN" == true ]]; then
       log_info "[DRY RUN] Would install package"
       return 0
   fi
   ```

### Shell Script Linting

Use ShellCheck to validate your scripts:

```bash
# Install shellcheck
brew install shellcheck

# Check a script
shellcheck setup-mac.sh
shellcheck functions/*.sh

# Auto-format (if shfmt is installed)
shfmt -w -i 4 setup-mac.sh
```

## Testing

### Manual Testing

1. **Always test in dry-run mode first**
   ```bash
   ./setup-mac.sh --dry-run
   ```

2. **Test specific components**
   ```bash
   ./setup-mac.sh --only homebrew,settings --dry-run
   ```

3. **Test on clean environment** (if possible)
   - Use a VM or separate user account
   - Test on both Apple Silicon and Intel if available

### Architecture Testing

Test on both architectures if possible:

- **Apple Silicon** (M1/M2/M3/M4): Primary target
- **Intel**: Secondary support

Include architecture checks in your code:
```bash
ARCH=$(uname -m)
log_info "Testing on architecture: $ARCH"
```

### What to Test

- ✅ Script runs without errors
- ✅ Dry-run mode works correctly
- ✅ Logging is clear and helpful
- ✅ Idempotency - safe to run multiple times
- ✅ Error handling works properly
- ✅ Both architectures supported (if applicable)

## Pull Request Process

### Before Submitting

1. ✅ **Test your changes** thoroughly
2. ✅ **Run ShellCheck** on modified scripts
3. ✅ **Update documentation** if needed
4. ✅ **Update README.md** if adding features
5. ✅ **Check for merge conflicts**

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on Apple Silicon
- [ ] Tested on Intel
- [ ] Tested in dry-run mode
- [ ] Verified idempotency

## Checklist
- [ ] Code follows project style guidelines
- [ ] ShellCheck passes without warnings
- [ ] Documentation updated
- [ ] No breaking changes (or documented if unavoidable)

## Screenshots (if applicable)
Add screenshots showing the change in action
```

### Review Process

1. At least one maintainer will review your PR
2. Address any requested changes
3. Once approved, your PR will be merged
4. Your contribution will be credited

## Project Structure

```
mac-setup/
├── setup-mac.sh              # Main entry point
├── Brewfile                  # Homebrew packages
├── README.md                 # User documentation
├── CONTRIBUTING.md           # This file
├── LICENSE                   # MIT License
├── .gitignore                # Git ignore rules
├── .editorconfig             # Editor configuration
├── functions/                # Modular function files
│   ├── xcode.sh              # Xcode & Rosetta 2
│   ├── homebrew.sh           # Homebrew installation
│   ├── macos-settings.sh     # System preferences
│   ├── packages.sh           # Package installation
│   ├── shell-config.sh       # Shell configuration
│   └── app-config.sh         # App replacements
└── logs/                     # Installation logs (gitignored)
```

## Adding New Features

### Adding a New Package

1. **For Homebrew packages**: Add to `Brewfile`
2. **For native apps**: Add to `functions/packages.sh`
3. **Update documentation**: Add to README.md

### Adding a New macOS Setting

1. Add to `functions/macos-settings.sh`
2. Use the consistent format:
   ```bash
   log_info "Setting description..."
   if [[ "$DRY_RUN" == true ]]; then
       log_info "[DRY RUN] Would apply setting"
   else
       defaults write domain key value
   fi
   ```

### Adding Architecture-Specific Code

```bash
# Detect architecture
ARCH=$(uname -m)

if [[ "$ARCH" == "arm64" ]]; then
    # Apple Silicon code
    download_url="https://example.com/app-arm64.dmg"
elif [[ "$ARCH" == "x86_64" ]]; then
    # Intel code
    download_url="https://example.com/app-x86_64.dmg"
fi
```

## Questions?

If you have questions about contributing:

1. Check existing [Issues](https://github.com/yourusername/mac-setup/issues)
2. Create a new issue with the `question` label
3. Be specific and provide context

## Recognition

Contributors will be recognized in the project. Thank you for helping improve this project!

---

**Happy Contributing!** 🎉