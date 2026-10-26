#!/usr/bin/env bash
set -euo pipefail

RESOURCE_GROUP="rg-enterprise-network-lab"

# Confirm Azure CLI authentication.
az account show --query name -o tsv >/dev/null

# Check if the resource group exists.
if [[ "$(az group exists --name "$RESOURCE_GROUP")" != "true" ]]; then
    echo "Lab resource group does not exist."
    exit 0
fi

# Warn before permanently deleting resources.
echo "WARNING: This will delete all resources in $RESOURCE_GROUP"

read -r -p "Type the resource group name to confirm: " CONFIRM

# Cancel if confirmation is incorrect.
if [[ "$CONFIRM" != "$RESOURCE_GROUP" ]]; then
    echo "Deletion canceled."
    exit 1
fi

# Delete the dedicated lab resource group.
az group delete \
    --name "$RESOURCE_GROUP" \
    --yes

echo "Lab resource group deletion completed."
