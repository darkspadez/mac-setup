#!/bin/bash

# Test script to diagnose color code issue

echo "=== Testing Color Variable Definitions ==="
echo ""

# Current definition (with double backslash)
RED_WRONG='\\033[0;31m'
GREEN_WRONG='\\033[0;32m'
NC_WRONG='\\033[0m'

# Correct definition (with single backslash)
RED_RIGHT='\033[0;31m'
GREEN_RIGHT='\033[0;32m'
NC_RIGHT='\033[0m'

echo "1. Using cat with WRONG definition (double backslash):"
cat << EOF
${RED_WRONG}This should be red${NC_WRONG}
${GREEN_WRONG}This should be green${NC_WRONG}
EOF

echo ""
echo "2. Using echo -e with WRONG definition (double backslash):"
echo -e "${RED_WRONG}This should be red${NC_WRONG}"
echo -e "${GREEN_WRONG}This should be green${NC_WRONG}"

echo ""
echo "3. Using cat with CORRECT definition (single backslash):"
cat << EOF
${RED_RIGHT}This should be red${NC_RIGHT}
${GREEN_RIGHT}This should be green${NC_RIGHT}
EOF

echo ""
echo "4. Using echo -e with CORRECT definition (single backslash):"
echo -e "${RED_RIGHT}This should be red${NC_RIGHT}"
echo -e "${GREEN_RIGHT}This should be green${NC_RIGHT}"

echo ""
echo "=== Variable Content Comparison ==="
echo "WRONG definition content: $RED_WRONG"
echo "RIGHT definition content: $RED_RIGHT"

echo ""
echo "=== Reproducing show_post_install_instructions behavior ==="
GREEN_WRONG='\\033[0;32m'
YELLOW_WRONG='\\033[1;33m'
BLUE_WRONG='\\033[0;34m'
NC_WRONG='\\033[0m'

echo "Current implementation output:"
cat << EOF

${GREEN_WRONG}Setup Complete!${NC_WRONG}

${YELLOW_WRONG}Manual Steps Required:${NC_WRONG}

1. ${BLUE_WRONG}Sign in to applications:${NC_WRONG}
   - 1Password
EOF