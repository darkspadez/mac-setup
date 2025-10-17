#!/bin/bash

echo "Testing defaults write syntax..."

# Test 1: Original problematic syntax
echo -e "\n=== Test 1: Original syntax with semicolon ==="
defaults write /tmp/test.plist LSHandlers -array-add \
    '{\"LSHandlerContentType\":\"public.unix-executable\",\"LSHandlerRoleAll\":\"dev.warp.Warp-Stable\";}' 2>&1
echo "Exit code: $?"

# Test 2: Without semicolon
echo -e "\n=== Test 2: Without semicolon ==="
defaults write /tmp/test2.plist LSHandlers -array-add \
    '{\"LSHandlerContentType\":\"public.unix-executable\",\"LSHandlerRoleAll\":\"dev.warp.Warp-Stable\"}' 2>&1
echo "Exit code: $?"

# Test 3: Using plist format
echo -e "\n=== Test 3: Using proper plist dict format ==="
defaults write /tmp/test3.plist LSHandlers -array-add \
    '<dict><key>LSHandlerContentType</key><string>public.unix-executable</string><key>LSHandlerRoleAll</key><string>dev.warp.Warp-Stable</string></dict>' 2>&1
echo "Exit code: $?"

# Show what was written
echo -e "\n=== Results ==="
[ -f /tmp/test.plist ] && echo "Test 1 created file" || echo "Test 1 failed"
[ -f /tmp/test2.plist ] && echo "Test 2 created file" || echo "Test 2 failed"  
[ -f /tmp/test3.plist ] && echo "Test 3 created file" || echo "Test 3 failed"

# Cleanup
rm -f /tmp/test*.plist