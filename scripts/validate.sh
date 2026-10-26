#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-enterprise-network-lab"
VNET="vnet-enterprise-lab"
FAILURES=0

# Compare an expected value with Azure's actual value.
check() {
    local label="$1"
    local expected="$2"
    local actual="$3"

    if [[ "$expected" == "$actual" ]]; then
        printf "PASS | %-30s | %s\n" "$label" "$actual"
    else
        printf "FAIL | %-30s | Expected: %s | Actual: %s\n" \
            "$label" "$expected" "$actual"
        FAILURES=$((FAILURES + 1))
    fi
}

# Validate an NSG security rule.
validate_rule() {
    local nsg="$1"
    local rule="$2"
    local direction="$3"

    local actual_direction actual_access actual_priority

    actual_direction=$(az network nsg rule show \
        -g "$RESOURCE_GROUP" --nsg-name "$nsg" -n "$rule" \
        --query direction -o tsv)

    actual_access=$(az network nsg rule show \
        -g "$RESOURCE_GROUP" --nsg-name "$nsg" -n "$rule" \
        --query access -o tsv)

    actual_priority=$(az network nsg rule show \
        -g "$RESOURCE_GROUP" --nsg-name "$nsg" -n "$rule" \
        --query priority -o tsv)

    check "$nsg direction" "$direction" "$actual_direction"
    check "$nsg access" "Deny" "$actual_access"
    check "$nsg priority" "100" "$actual_priority"
}

# Validate a subnet's associated NSG.
validate_subnet() {
    local subnet="$1"
    local expected_nsg="$2"
    local actual_id actual_nsg

    actual_id=$(az network vnet subnet show \
        -g "$RESOURCE_GROUP" --vnet-name "$VNET" \
        -n "$subnet" --query networkSecurityGroup.id -o tsv)

    actual_nsg="${actual_id##*/}"
    check "$subnet association" "$expected_nsg" "$actual_nsg"
}

echo "Azure Network Configuration Validation"
echo "--------------------------------------"

validate_rule "nsg-app" "Deny-App-to-Admin" "Outbound"
validate_rule "nsg-admin" "Deny-App-Inbound" "Inbound"

validate_subnet "snet-app" "nsg-app"
validate_subnet "snet-admin" "nsg-admin"

echo "--------------------------------------"

if [[ "$FAILURES" -eq 0 ]]; then
    echo "PASS: All configuration checks passed."
    echo "Live traffic testing was NOT performed."
else
    echo "FAIL: $FAILURES checks failed."
    exit 1
fi
