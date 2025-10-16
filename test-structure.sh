#!/bin/bash

# Test script to verify the Mac setup script structure (without execution)

echo "Verifying Mac Setup Script Structure..."
echo "======================================="

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if main script exists
echo ""
echo "Checking main script..."
if [[ -f "${SCRIPT_DIR}/setup-mac.sh" ]]; then
    echo "✅ setup-mac.sh: Found"
    if [[ -x "${SCRIPT_DIR}/setup-mac.sh" ]]; then
        echo "✅ setup-mac.sh: Executable"
    else
        echo "❌ setup-mac.sh: Not executable"
    fi
else
    echo "❌ setup-mac.sh: Missing"
fi

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
    lines=$(wc -l < "${SCRIPT_DIR}/README.md")
    echo "   → Contains $lines lines"
else
    echo "❌ README.md: Missing"
fi

# Check if plan exists
echo ""
if [[ -f "${SCRIPT_DIR}/mac-setup-plan.md" ]]; then
    echo "✅ mac-setup-plan.md: Found"
else
    echo "❌ mac-setup-plan.md: Missing"
fi

# Check total lines of code
echo ""
echo "Code Statistics:"
echo "----------------"
total_lines=0

if [[ -f "${SCRIPT_DIR}/setup-mac.sh" ]]; then
    lines=$(wc -l < "${SCRIPT_DIR}/setup-mac.sh")
    echo "Main script: $lines lines"
    total_lines=$((total_lines + lines))
fi

for func_file in functions/*.sh; do
    if [[ -f "$func_file" ]]; then
        lines=$(wc -l < "$func_file")
        filename=$(basename "$func_file")
        echo "$filename: $lines lines"
        total_lines=$((total_lines + lines))
    fi
done

echo "----------------"
echo "Total code lines: $total_lines"

echo ""
echo "======================================="
echo "Structure verification complete!"
echo ""
echo "To use this script on a Mac:"
echo "1. Transfer all files to your Mac"
echo "2. Run: ./setup-mac.sh --help"
echo "3. For a dry run: ./setup-mac.sh --dry-run"
echo "4. For full setup: ./setup-mac.sh"