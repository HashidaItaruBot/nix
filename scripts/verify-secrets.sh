#!/usr/bin/env bash
# verify-secrets.sh - Verify no secrets are leaked to the nix store
#
# This script checks for leaked secrets in the nix store by looking for:
# - SOPS encryption markers (ENC[)
# - Age encryption markers (age1) in yaml files
#
# Exit codes:
#   0 - No secrets found (clean)
#   1 - Secrets found (leaked)

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Checking for leaked secrets in /nix/store..."

# Track if any issues are found
ISSUES_FOUND=0

# Maximum number of files to check (to avoid scanning entire store)
MAX_FILES=100

# Function to check for SOPS markers
check_sops_markers() {
    echo "Checking for SOPS encryption markers (ENC[)..."

    local found=0
    local count=0

    # Use a temp file to store results to avoid subshell issues
    local tmpfile
    tmpfile=$(mktemp)
    find /nix/store -maxdepth 2 -type f -name "*.nix" 2>/dev/null | head -n "$MAX_FILES" > "$tmpfile"

    while IFS= read -r store_path; do
        [[ -z "$store_path" ]] && continue
        ((count++)) || true
        if grep -q "ENC\[" "$store_path" 2>/dev/null; then
            echo -e "${RED}ERROR: SOPS marker ENC[ found in: $store_path${NC}"
            found=1
        fi
    done < "$tmpfile"

    rm -f "$tmpfile"

    if [[ $found -eq 1 ]]; then
        return 1
    fi

    echo -e "${GREEN}  No SOPS markers found in sampled .nix files (checked $count files)${NC}"
    return 0
}

# Function to check for age encryption keys in yaml files
check_age_markers() {
    echo "Checking for age encryption markers in yaml files..."

    local found=0
    local count=0

    local tmpfile
    tmpfile=$(mktemp)
    find /nix/store -maxdepth 2 -type f -name "*.yaml" 2>/dev/null | head -n "$MAX_FILES" > "$tmpfile"

    while IFS= read -r store_path; do
        [[ -z "$store_path" ]] && continue
        ((count++)) || true
        if grep -q "age1[a-z0-9]\{50,\}" "$store_path" 2>/dev/null; then
            # age keys in .sops.yaml are expected, but secrets content shouldn't be in store
            if [[ ! "$store_path" =~ \.sops\.yaml$ ]]; then
                echo -e "${YELLOW}WARNING: Age key pattern found in: $store_path${NC}"
                found=1
            fi
        fi
    done < "$tmpfile"

    rm -f "$tmpfile"

    if [[ $found -eq 1 ]]; then
        echo -e "${YELLOW}  Age key patterns found - review manually if expected${NC}"
    else
        echo -e "${GREEN}  No age key patterns found in sampled yaml files (checked $count files)${NC}"
    fi

    return 0
}

# Function to check for common secret patterns
check_common_patterns() {
    echo "Checking for common secret patterns..."

    local found=0
    local count=0

    # Patterns that indicate leaked secrets
    local patterns=(
        "password\s*=\s*\"[^\"]+\""
        "api_key\s*=\s*\"[^\"]+\""
        "secret\s*=\s*\"[^\"]+\""
        "token\s*=\s*\"[^\"]+\""
    )

    local tmpfile
    tmpfile=$(mktemp)
    find /nix/store -maxdepth 2 -type f -name "*.nix" 2>/dev/null | head -n "$MAX_FILES" > "$tmpfile"

    while IFS= read -r store_path; do
        [[ -z "$store_path" ]] && continue
        ((count++)) || true
        for pattern in "${patterns[@]}"; do
            if grep -qE "$pattern" "$store_path" 2>/dev/null; then
                echo -e "${RED}ERROR: Potential secret pattern found in: $store_path${NC}"
                echo -e "${RED}  Pattern: $pattern${NC}"
                found=1
            fi
        done
    done < "$tmpfile"

    rm -f "$tmpfile"

    if [[ $found -eq 1 ]]; then
        return 1
    fi

    echo -e "${GREEN}  No common secret patterns found in sampled files (checked $count files)${NC}"
    return 0
}

# Run all checks
echo ""

# Check 1: SOPS markers
if ! check_sops_markers; then
    ISSUES_FOUND=1
fi

# Check 2: Age markers (warning only)
check_age_markers

# Check 3: Common patterns
if ! check_common_patterns; then
    ISSUES_FOUND=1
fi

echo ""

# Final result
if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}OK: No secrets found in /nix/store${NC}"
    exit 0
else
    echo -e "${RED}FAIL: Potential secrets found in /nix/store${NC}"
    echo -e "${YELLOW}Review the output above and ensure secrets are properly encrypted${NC}"
    exit 1
fi