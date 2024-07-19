# Description:
# This script utilises replication metadata to identify the most recent changes to the 'member' attribute of Tier Zero groups. The results are stored in a CSV file and also displayed in the console.
#
# Prerequisites:
# - Ensure you have the Active Directory module installed.
# - Run this script with adequate permissions to query Active Directory objects.
#
# Usage:
# 1. Specify the desired domain controller in the `$domainController` variable.
# 2. Ensure the group names in the `$groupNames` array are accurate.
# 3. Execute the script in a PowerShell environment with access to the domain controller.

# Import the Active Directory module
Import-Module ActiveDirectory

# Initialise the list of groups
$groupNames = @(
    "Account Operators",
    "Administrators",
    "Allowed RODC Password",
    "Backup Operators",
    "Cryptographic Operators",
    "Denied RODC Password",
    "Distributed COM Users",
    "Domain Admins",
    "Domain Controllers",
    "DNS Admins",
    "Enterprise Admins",
    "Enterprise Read-only Domain Controllers"
    "Group Policy Creator Owners",
    "Performance Log Users",
    "Print Operators",
    "Read-only Domain Controllers",
    "Schema Admins",
    "Server Operators",
    "DNS Admins",
    ""
)

# Specify the domain controller
$domainController = "host.ad.acme.com"

# Create an array to store the most recent change information
$T0GroupChanges = @()

# Get the distinguished names of the groups and loop through each group
foreach ($groupName in $groupNames) {
    $group = Get-ADGroup -Filter { Name -eq $groupName } -Server $domainController
    if ($group) {
        $groupDN = $group.DistinguishedName
        $metadata = Get-ADReplicationAttributeMetadata -Object $groupDN -Server $domainController
        $mostRecentChange = $metadata | Sort-Object LastOriginatingChangeTime -Descending | Select-Object -First 1

        if ($mostRecentChange -and $mostRecentChange.AttributeName -eq "member") {
            $T0GroupChanges += [PSCustomObject]@{
                GroupName       = $groupName
                AttributeName   = $mostRecentChange.AttributeName
                LastChangeTime  = $mostRecentChange.LastOriginatingChangeTime
            }
        }
    } else {
        Write-Host "Group '$groupName' not found." -ForegroundColor Red
    }
}

# Output the recent changes to a CSV file and console
$T0GroupChanges | Export-Csv -Path "TierZeroGroupChanges.csv" -NoTypeInformation
$T0GroupChanges | Format-Table -AutoSize