Azure Data Explorer (ADX)
Overview
Azure Data Explorer (ADX) is a fast, fully managed data analytics service designed for real-time and time-series analysis on large volumes of data streams.
This request originates from GIS Limited-Use Azure LogicApp Service Enablement and includes:

An amendment to a previously approved Limited Use Service Enablement to allow additional resource access for compliance with internal standards.

The inclusion of three new Azure resource types in the allowlist for Azure LogicApp Service:

Microsoft.Web/Sites

Microsoft.Web/ServerFarms

Microsoft.Kusto/Clusters

Purpose
The main objectives of using Azure Data Explorer include:

Enabling a standard Logic App to query data and meet GIS requirements for resource monitoring.

Triggering scheduled Logic Apps based on a desired run frequency using predefined KQL statements.

Supporting audit requirements by querying Azure data and generating alerts in Microsoft Sentinel for email notifications, statistical modeling, and anomaly detection.

ADX Resource Exemptions for Sentinel Policy
To set up and manage Azure Data Explorer, the following essential resources must be considered for exemption in Sentinel policies:

azurerm_kusto_cluster

Core computing resource representing the ADX cluster for data storage and querying.

azurerm_kusto_database

Logical container within the Kusto cluster where data is stored and queried.

azurerm_kusto_cluster_customer_managed_key

Enables the integration of a customer-managed encryption key (CMK) to secure data stored in the cluster.

Built-In Azure Policy Definitions for ADX
To ensure security and compliance, Azure provides several built-in policy definitions specific to Azure Data Explorer. These policies default to Audit mode unless otherwise specified.
Reference: Azure ADX Policy Definitions

Azure Data Explorer Encryption at Rest Should Use a Customer-Managed Key

Disk Encryption Should Be Enabled on Azure Data Explorer

Double Encryption Should Be Enabled on Azure Data Explorer

Virtual Network Injection Should Be Enabled for Azure Data Explorer

Azure Data Explorer Should Use a SKU That Supports Private Link

Public Network Access Should Be Disabled on Azure Data Explorer

Configure Azure Data Explorer to Disable Public Network Access

Azure Data Explorer Cluster Should Use a Private Link

Configure Azure Data Explorer Clusters with Private Endpoints
