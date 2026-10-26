# Azure Enterprise Network Segmentation

## Project Overview

This hands-on Azure infrastructure project demonstrates how network segmentation and Network Security Groups (NSGs) can be used to reduce unnecessary access between application and administrative environments.

The lab simulates an enterprise security requirement and includes infrastructure deployment, network access controls, troubleshooting, and Azure CLI configuration validation.

**Project status:** Network configuration completed and validated using Azure CLI. Live traffic testing has not yet been performed.

## Business Problem

Organizations often operate application and administrative systems within the same cloud environment.

Without appropriately configured network security controls, systems may communicate more broadly than business requirements allow, increasing the potential for lateral movement following a security incident.

**Objective:** Restrict application-initiated connections to administrative infrastructure while maintaining a manageable Azure network architecture.

## Technologies Used

- Microsoft Azure
- Azure Virtual Network (VNet)
- Azure Subnets
- Network Security Groups (NSGs)
- Azure Cloud Shell
- Azure CLI
- Azure Network Watcher

## Architecture

**Azure Region:** Central US

**Resource Group:** `rg-enterprise-network-lab`

**Virtual Network:** `vnet-enterprise-lab`

**Address Space:** `10.10.0.0/16`

| Subnet | Address Range | Associated NSG |
|---|---|---|
| Application | `10.10.1.0/24` | `nsg-app` |
| Administration | `10.10.2.0/24` | `nsg-admin` |

Both subnets are deployed within the same Azure Virtual Network.

## Security Implementation

### Application Subnet

The `nsg-app` Network Security Group contains a custom outbound rule:

| Setting | Value |
|---|---|
| Rule | Deny-App-to-Admin |
| Direction | Outbound |
| Priority | 100 |
| Source | 10.10.1.0/24 |
| Destination | 10.10.2.0/24 |
| Protocol / Ports | Any |
| Action | Deny |

### Administration Subnet

The `nsg-admin` Network Security Group contains a complementary inbound restriction:

| Setting | Value |
|---|---|
| Rule | Deny-App-Inbound |
| Direction | Inbound |
| Priority | 100 |
| Source | 10.10.1.0/24 |
| Destination | 10.10.2.0/24 |
| Protocol / Ports | Any |
| Action | Deny |

These rules are designed to prevent application-subnet systems from initiating connections to the administration subnet.

## Troubleshooting Experience

During implementation, I discovered that the administration NSG rule had been configured with the incorrect traffic direction.

**Problem:** The intended inbound rule was configured as an outbound rule.

**Investigation:** I used Azure CLI to inspect the rule's properties and discovered that its direction was set to `Outbound`.

**Resolution:** I corrected the configuration so the rule used the intended `Inbound` direction.

**Verification:** Azure CLI confirmed that the corrected rule had direction `Inbound`, action `Deny`, and priority `100`.

This reinforced the importance of validating security configuration instead of assuming a deployment is correct.

## Validation Results

I used Azure CLI to confirm:

- The application NSG outbound deny rule was configured correctly.
- The administration NSG inbound deny rule was configured correctly after troubleshooting.
- Both subnets were associated with their intended NSGs.

**Validation limitation:** These checks confirm Azure resource configuration, not actual packet delivery. Live connectivity testing with suitable test workloads remains outstanding.

## What I Would Do Differently in an Enterprise Environment

For a production deployment, I would evaluate:

1. **Infrastructure as Code:** Use Terraform or Bicep to deploy and version-control network infrastructure consistently.
2. **Least-privilege connectivity:** Define approved communication paths and allow only required protocols and ports.
3. **Centralized monitoring:** Use appropriate network telemetry, Azure Monitor, and alerting to investigate suspicious activity.
4. **Network architecture:** Evaluate hub-and-spoke connectivity and centralized security controls based on business requirements.
5. **Security governance:** Apply Azure Policy, RBAC, change management, and configuration validation.
6. **High availability:** Design critical networking components around availability and recovery requirements.
7. **Cost management:** Evaluate the operational benefits and costs of additional services before deploying them.

The lab intentionally uses a smaller architecture than a full production environment.

## Lessons Learned

This project strengthened my practical understanding of Azure networking, subnet segmentation, NSG rule direction, security rule priorities, and configuration verification with Azure CLI.

The main takeaway was the importance of verifying security controls after implementation and documenting how configuration mistakes are identified and corrected.

## Next Improvements

- Conduct live connectivity testing.
- Add infrastructure deployment automation.
- Publish an architecture diagram and redacted configuration screenshots.
- Expand validation with repeatable security checks.
- Document cleanup and any incurred Azure costs.

## Project Context

This is an independently built educational lab representing a realistic enterprise networking scenario. It is not presented as a production deployment or work completed for an employer.
