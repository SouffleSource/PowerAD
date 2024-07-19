# Description:
# This script retrieves all user and computer objects that are members of specified Tier Zero AD groups. It also gathers
# the other groups that these users and computers are members of (dependencies) and outputs this information into a CSV 
# file for further analysis.
#
# Prerequisites:
# - Ensure you have the Active Directory module installed.
# - Run this script with adequate permissions to query Active Directory objects.
#
# Usage:
# 1. Review and, if necessary, customise the list of groups in the $groups array.
# 2. Execute the script in a PowerShell environment that has access to the AD module and necessary permissions.

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the list of groups
$groups = @(
    "Account Operators",
    "Administrators",
    "Allowed RODC Password Replication Group",
    "Backup Operators",
    "Cryptographic Operators",
    "Denied RODC Password Replication Group",
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
    "DnsAdmins"
)

$output = @()

foreach ($groupName in $groups) {
    # Get the group object
    $groupObj = Get-ADGroup -Filter "Name -eq '$groupName'"
    
    if ($groupObj) {
        # Get the members of the group
        $members = Get-ADGroupMember -Identity $groupObj -Recursive
        
        foreach ($member in $members) {
            # Check if the member is a user or a computer
            if ($member.objectClass -eq 'user') {
                # Get the group membership for each user member
                $memberGroups = Get-ADUser -Identity $member -Property MemberOf | Select-Object -ExpandProperty MemberOf
            } elseif ($member.objectClass -eq 'computer') {
                # Get the group membership for each computer member
                $memberGroups = Get-ADComputer -Identity $member -Property MemberOf | Select-Object -ExpandProperty MemberOf
            }
            
            foreach ($memberGroup in $memberGroups) {
                # Resolve DN to group name
                $resolvedGroupName = (Get-ADGroup -Identity $memberGroup).Name
                $output += [PSCustomObject]@{
                    GroupName = $groupObj.Name
                    MemberName = $member.SamAccountName
                    MemberOfGroup = $resolvedGroupName
                }
            }
        }
    } else {
        Write-Warning "Group '$groupName' not found."
    }
}

# Export
$path = "ADTierZeroObjects.csv"
$output | Export-Csv -Path $path -NoTypeInformation
$ouHierarchy | Format-Table -AutoSize
Write-Output "Report generated: $path"