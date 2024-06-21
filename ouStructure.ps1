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
$outputPath = "C:\Users\daniel776\OneDrive - Baillie Gifford & Co\Desktop\OUs.csv"

# Export the OU hierarchy to a CSV file
$ouHierarchy | Export-Csv -Path $outputPath -NoTypeInformation -Encoding utf8

Write-Host "OU hierarchy with object counts exported to $outputPath"