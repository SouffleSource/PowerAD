# Description:
# This script utilises replication metadata to identify the most recent changes to identity attributes of Tier Zero computers, including groups that provide access to them. It fetches the last logon timestamp, password last set date, creation date, operating system, and metadata. The results are exported to a CSV file and displayed in the console.
#
# Prerequisites:
# - Ensure you have the Active Directory module installed.
# - Run this script with adequate permissions to query Active Directory objects.
#
# Usage:
# 1. Specify the domain controller in the `$domainController` variable.
# 2. Provide the list of computer names in the `$computerNames` array.
# 3. Execute the script in a PowerShell environment with access to the domain controller.

Import-Module ActiveDirectory

$computerNames = @(
    "DC1", 
    "DC2", 
    "PKI1", 
    "PKI2"
)

# Specify the domain controller
$domainController = "host.ad.acme.com"

# Create an array to store the attribute information
$attributes = @()

# Get the relevant attributes for each computer object
foreach ($computerName in $computerNames) {
    $computer = Get-ADComputer -Filter { Name -eq $computerName } -Property lastLogonTimestamp, pwdLastSet, whenCreated, operatingSystem -Server $domainController
    if ($computer) {
        $computerDN = $computer.DistinguishedName
        $metadata = Get-ADReplicationAttributeMetadata -Object $computerDN -Server $domainController

        # Find the last change of group membership
        $lastGroupChange = $metadata | Where-Object { $_.AttributeName -eq "member" } | Sort-Object LastOriginatingChangeTime -Descending | Select-Object -First 1

        $lastLogonTimestamp = if ($computer.lastLogonTimestamp) { [DateTime]::FromFileTime($computer.lastLogonTimestamp) } else { $null }
        $pwdLastSet = if ($computer.pwdLastSet) { [DateTime]::FromFileTime($computer.pwdLastSet) } else { $null }

        $attributes += [PSCustomObject]@{
            ComputerName          = $computerName
            LastLogonTimestamp    = $lastLogonTimestamp
            LastGroupChange       = if ($lastGroupChange) { $lastGroupChange.LastOriginatingChangeTime } else { $null }
            PwdLastSet            = $pwdLastSet
            WhenCreated           = $computer.whenCreated
            OperatingSystem       = $computer.operatingSystem
        }
    } else {
        Write-Host "Computer '$computerName' not found." -ForegroundColor Red
    }
}

# Output the recent changes to a CSV file and console
$attributes | Export-Csv -Path "TierZeroComputerChanges.csv" -NoTypeInformation
$attributes | Format-Table -AutoSize