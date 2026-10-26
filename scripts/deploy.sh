#!/usr/bin/env bash
set -euo pipefail

# Azure Enterprise Network Segmentation Lab
RESOURCE_GROUP="rg-enterprise-network-lab"
LOCATION="centralus"
VNET="vnet-enterprise-lab"

APP_SUBNET="snet-app"
ADMIN_SUBNET="snet-admin"
APP_NSG="nsg-app"
ADMIN_NSG="nsg-admin"

# Stop if the resource group already exists.
if [[ "$(az group exists --name "$RESOURCE_GROUP")" == "true" ]]; then
    echo "Lab already exists. Deployment canceled."
    exit 1
fi

# Create resource group.
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION"

# Create VNet and application subnet.
az network vnet create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VNET" \
    --location "$LOCATION" \
    --address-prefixes 10.10.0.0/16 \
    --subnet-name "$APP_SUBNET" \
    --subnet-prefixes 10.10.1.0/24

# Create admin subnet.
az network vnet subnet create \
    --resource-group "$RESOURCE_GROUP" \
    --vnet-name "$VNET" \
    --name "$ADMIN_SUBNET" \
    --address-prefixes 10.10.2.0/24

# Create both Network Security Groups.
for NSG in "$APP_NSG" "$ADMIN_NSG"; do
    az network nsg create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$NSG" \
        --location "$LOCATION"
done

# Attach each NSG to its subnet.
az network vnet subnet update \
    --resource-group "$RESOURCE_GROUP" \
    --vnet-name "$VNET" \
    --name "$APP_SUBNET" \
    --network-security-group "$APP_NSG"

az network vnet subnet update \
    --resource-group "$RESOURCE_GROUP" \
    --vnet-name "$VNET" \
    --name "$ADMIN_SUBNET" \
    --network-security-group "$ADMIN_NSG"

# Block outbound traffic from App to Admin.
az network nsg rule create \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$APP_NSG" \
    --name Deny-App-to-Admin \
    --priority 100 \
    --direction Outbound \
    --access Deny \
    --protocol '*' \
    --source-address-prefixes 10.10.1.0/24 \
    --source-port-ranges '*' \
    --destination-address-prefixes 10.10.2.0/24 \
    --destination-port-ranges '*'

# Block inbound traffic from App to Admin.
az network nsg rule create \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$ADMIN_NSG" \
    --name Deny-App-Inbound \
    --priority 100 \
    --direction Inbound \
    --access Deny \
    --protocol '*' \
    --source-address-prefixes 10.10.1.0/24 \
    --source-port-ranges '*' \
    --destination-address-prefixes 10.10.2.0/24 \
    --destination-port-ranges '*'

echo "Deployment complete. Run validate.sh to check the configuration."
