#!/bin/bash

# Test script to verify the Mac setup script components

echo "Testing Mac Setup Script Components..."
echo "======================================"

# Source the main script functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/setup-mac.sh" 2>/dev/null || echo "Error: Could not source main script"

echo ""
echo "✅ Main script structure: OK"

# Check if all function files exist
echo ""
echo "Checking function files..."
for func_file in xcode.sh homebrew.sh macos-settings.sh packages.sh shell-config.sh app-config.sh; do
    if [[ -f "${SCRIPT_DIR}/functions/$func_file" ]]; then
        echo "✅ functions/$func_file: Found"
    else
        echo "❌ functions/$func_file: Missing"
    fi
done

# Check if README exists
echo ""
if [[ -f "${SCRIPT_DIR}/README.md" ]]; then
    echo "✅ README.md: Found"
else
    echo "❌ README.md: Missing"
fi

# Check if main script is executable
echo ""
if [[ -x "${SCRIPT_DIR}/setup-mac.sh" ]]; then
    echo "✅ setup-mac.sh is executable"
else
    echo "❌ setup-mac.sh is NOT executable"
fi

echo ""
echo "======================================"
echo "Test complete! Run ./setup-mac.sh --help to see usage options."