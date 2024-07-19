# Description:
# This script searches Active Directory for groups whose names contain specific strings provided by the user. 
# It retrieves details about these groups, including descriptions, notes, members, and their organisational unit paths.
# The results are exported into CSV files, named after each search string.
# IMPORTANT: It will return an unspecified error on Get-ADGroupMember if the membership is very large - ignore it and it will continue.
#
# Prerequisites:
# - Ensure you have the Active Directory module installed.
# - Run this script with adequate permissions to query Active Directory.
#
# Usage:
# 1. Run the script in a PowerShell environment with the required permissions.
# 2. Input the search strings when prompted, separated by commas. 

# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt the user for input strings
$inputStrings = Read-Host "Please enter the search strings, separated by commas"

# Split the input string into an array of search strings
$searchStrings = $inputStrings -split ','

foreach ($searchString in $searchStrings) {
    $searchString = $searchString.Trim()
    $reportData = @()

     # Search for groups containing the current search string in their names
     $groups = Get-ADGroup -Filter "Name -like '*$searchString*'" -Properties Description, Info

     # Check if any groups were found
     if ($groups.Count -eq 0) {
         Write-Warning "No groups found matching the search string: '$searchString'"
     } else {
        foreach ($group in $groups) {
        # Populate $reportData
        $members = Get-ADGroupMember -Identity $group.DistinguishedName | Select-Object -ExpandProperty SamAccountName -ErrorAction SilentlyContinue -Verbose
        if ($members.Count -eq 0) {
            $members = @("None")
        }
        $membersString = $members -join ", "
        $groupDescription = $group.Description
        $groupNotes = $group.Info
        $ouPath = $group.DistinguishedName -replace '^CN=.*?,',''

        $reportData += [PSCustomObject]@{
            GroupName     = $group.Name
            Description   = $groupDescription
            Notes         = $groupNotes
            Members       = $membersString
            OU            = $ouPath
        }
    }

    # Output to a file named after the search string
    $path = "$searchString.csv"
    $reportData | Export-Csv -Path $path -NoTypeInformation
    Write-Output "Report generated: $path"
 }
}