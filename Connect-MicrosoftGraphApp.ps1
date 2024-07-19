# Description:
# This script demonstrates how to connect to Microsoft Graph as an application using delegated access. It uses secrets stored in Microsoft PowerShell SecretManagement and the Microsoft Graph PowerShell SDK.
#
# Prerequisites:
# - Ensure you have installed the Microsoft.Graph.Authentication and Microsoft.PowerShell.SecretManagement modules.
# - Set up an Azure AD application with the necessary permissions and grant admin consent (https://learn.microsoft.com/en-us/powershell/microsoftgraph/authentication-commands?view=graph-powershell-1.0#use-delegated-access-with-a-custom-application-for-microsoft-graph-powershell)
# - Set up secret storage in Microsoft PowerShell SecretManagement with the necessary client ID, tenant ID, and client secret.
#
# Usage:
# 1. Store your client ID, tenant ID, and client secret using SecretManagement:
#    ```powershell
#    Set-Secret -Name ClientId -Secret "<your-client-id>"
#    Set-Secret -Name TenantId -Secret "<your-tenant-id>"
#    Set-Secret -Name ClientSecret -Secret "<your-client-secret>"
#    ```
# 2. Run the script in a PowerShell environment.

Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.PowerShell.SecretManagement

# Fetch secrets
Write-Verbose "Retrieving ClientId from Secret Management" -Verbose
$clientId = Get-Secret -Name ClientId -AsPlainText
$tenantId = Get-Secret -Name TenantId -AsPlainText
$clientSecret = Get-Secret -Name ClientSecret 

# Create a PSCredential object, using the client ID as the username and the secure client secret as the password
$clientSecretCredential = New-Object System.Management.Automation.PSCredential ($clientId, $clientSecret)

# Connect to Microsoft Graph using the PSCredential object
Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $clientSecretCredential -Scopes "https://graph.microsoft.com/.default"

# Add your Graph functions below