Import-Module Microsoft.Graph.Authentication
Import-Module Microsoft.Graph.DirectoryObjects
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

# Function to get role members
function Get-RoleMembers {
    param (
        [string]$roleTemplateId
    )

    try {
        $directoryRole = Get-MgDirectoryRole -Filter "roleTemplateId eq '$roleTemplateId'"
        
        if ($directoryRole -and $directoryRole.Count -eq 1) {
            $directoryRoleId = $directoryRole[0].Id

            # Fetch role members
            $members = Get-MgDirectoryRoleMember -DirectoryRoleId $directoryRoleId
            return $members
        } else {
            Write-Warning "Role with template ID '$roleTemplateId' not found or found multiple roles."
            return $null
        }
    } catch {
        Write-Error "Error fetching role members: $_"
        return $null
    }
}

# Define roles and their template IDs
$roles = @(
    @{ Name = "Global Administrator"; TemplateId = "62e90394-69f5-4237-9190-012177145e10" },
    @{ Name = "Privileged Authentication Administrator"; TemplateId = "1f34cd9f-5154-464d-a281-e03a4de9b3f3" },
    @{ Name = "Privileged Role Administrator"; TemplateId = "e8611ab8-c189-46e8-94e1-60213ab1f814" },
    @{ Name = "Partner Tier2 Support"; TemplateId = "fbd5f142-16b2-4a64-9877-9e82552b5ccb" },
    @{ Name = "Security Administrator"; TemplateId = "e3db3c22-6ea7-40e7-bb26-68039c82b34b" },
    @{ Name = "Intune Administrator"; TemplateId = "882e1d0f-45a7-4ae0-84ff-7fa19d1129ef" },
    @{ Name = "Knowledge Administrator"; TemplateId = "df7ab8d0-d064-4d37-b23b-3cf1aab9897d" },
    @{ Name = "Application Administrator"; TemplateId = "9c094953-4995-41c8-8104-0d9a7bc0a838" }
)

# Fetch and display role members
foreach ($role in $roles) {
    $roleMembers = Get-RoleMembers -roleTemplateId $role.TemplateId
    Write-Output "Members of '${role.Name}':"
    if ($roleMembers) {
        $roleMembers | ForEach-Object { Write-Output $_.DisplayName }
    } else {
        Write-Output "No members found."
    }
    Write-Output "`n"
}