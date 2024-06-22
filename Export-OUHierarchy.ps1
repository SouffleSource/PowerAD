# This script retrieves organizational unit (OU) data from Active Directory (AD) and exports it to a CSV file. 
# The exported data includes hierarchical parent-child relationships and object counts within each OU. This 
# CSV can be imported into visualisation tools like Lucidchart for better analysis of the AD structure.
#
# Prerequisites:
# - Ensure you have the Active Directory module installed.
# - Run this script with adequate permissions to query Active Directory objects.
#
# Usage:
# 1. Customise the outputPath variable to specify where you want the CSV file to be saved.
# 2. Execute the script in a PowerShell environment that has access to the AD module and necessary permissions.


# Import the Active Directory module
Import-Module ActiveDirectory

# Function to recursively fetch OUs and create a list with parent-child relationships
function Get-ADOUHierarchy {
    param (
        [string]$ParentOU = ""
    )

    $ous = Get-ADOrganizationalUnit -Filter * -SearchBase $ParentOU -SearchScope OneLevel
    $result = @()

    foreach ($ou in $ous) {
        $objectCount = (Get-ADObject -Filter * -SearchBase $ou.DistinguishedName | Measure-Object).Count
        $result += [PSCustomObject]@{
            Name = $ou.Name
            DistinguishedName = $ou.DistinguishedName
            ParentDistinguishedName = $ParentOU
            ObjectCount = $objectCount
        }
        $result += Get-ADOUHierarchy -ParentOU $ou.DistinguishedName
    }
    return $result
}

# Fetch the root domain's distinguished name
$rootDomain = (Get-ADDomain).DistinguishedName

# Get the OU hierarchy starting from the root
$ouHierarchy = Get-ADOUHierarchy -ParentOU $rootDomain

# Define the output path
$outputPath = "[Path]"

# Export the OU hierarchy to a CSV file
$ouHierarchy | Export-Csv -Path $outputPath -NoTypeInformation -Encoding utf8

Write-Host "OU hierarchy with object counts exported to $outputPath"