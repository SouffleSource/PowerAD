 # Description:
# This script retrieves all user and computer objects associated with Tier Zero Active Directory groups and AzureAD (EntraID) Roles.
# It collects the membership details from both environments and exports this data into a CSV file for further analysis.
#
# Prerequisites:
# - Ensure you have the Active Directory and Microsoft Graph modules installed.
# - You must have appropriate permissions to query both Active Directory and Microsoft Graph.
# 
# Usage:
# Review and customise the list of AD groups in the `$adGroups` array and the list of EntraID roles in the `$azureAdRoles` array as needed.
# Execute the script in a PowerShell environment that has access to the Active Directory and Microsoft Graph modules with the necessary permissions.
 
 
 # Import the required modules
 Import-Module ActiveDirectory
 if (-not (Get-Module -Name ActiveDirectory)) {
     Write-Error "ActiveDirectory module is not loaded properly."
 }

 Import-Module Microsoft.Graph
 if (-not (Get-Module -Name Microsoft.Graph)) {
     Write-Error "Microsoft.Graph module is not loaded properly."
 }

 # Authenticate to Microsoft Graph
 Connect-MgGraph -Scopes "RoleManagement.Read.All", "Directory.Read.All"

 # Define the list of AD groups
 $adGroups = @(
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
     "Enterprise Read-only Domain Controllers",
     "Group Policy Creator Owners",
     "Performance Log Users",
     "Print Operators",
     "Read-only Domain Controllers",
     "Schema Admins",
     "Server Operators",
     "Dns Admins"
 )

 # Define the list of EntraID (AzureAD) roles
 $azureAdRoles = @(
     "Global Administrator",
     "Privileged Authentication Administrator",
     "Privileged Role Administrator",
     "Partner Tier2 Support",
     "Security Administrator",
     "Intune Administrator",
     "Knowledge Administrator",
     "Application Administrator"
 )

 $output = @()

 $totalAdGroups = $adGroups.Count
 $currentAdGroupIndex = 0

 # Fetch members of AD groups
 foreach ($groupName in $adGroups) {
     $currentAdGroupIndex++
     $groupObj = Get-ADGroup -Filter "Name -eq '$groupName'"
     
     if ($groupObj) {
         $members = Get-ADGroupMember -Identity $groupObj -Recursive
         
         foreach ($member in $members) {
             if ($member.objectClass -eq 'user') {
                 $memberGroups = Get-ADUser -Identity $member -Property MemberOf | Select-Object -ExpandProperty MemberOf
             } elseif ($member.objectClass -eq 'computer') {
                 $memberGroups = Get-ADComputer -Identity $member -Property MemberOf | Select-Object -ExpandProperty MemberOf
             }
             
             foreach ($memberGroup in $memberGroups) {
                 if ($memberGroup) {
                     $resolvedGroupName = (Get-ADGroup -Identity $memberGroup).Name
                     $output += [PSCustomObject]@{
                         GroupName = $groupObj.Name
                         MemberName = $member.SamAccountName
                         MemberOfGroup = $resolvedGroupName
                         Source = "On-Premises AD"
                     }
                 }
             }
         }
         Write-Output "Completed processing AD group: $groupName"
     } else {
         Write-Warning "Group '$groupName' not found."
     }

     Write-Progress -Activity "Processing AD Groups" -Status "Processing $groupName" -PercentComplete (($currentAdGroupIndex / $totalAdGroups) * 100)
 }

 $totalAzureAdRoles = $azureAdRoles.Count
 $currentAzureAdRoleIndex = 0

 # Fetch users with specific Azure AD roles
 foreach ($roleName in $azureAdRoles) {
     $currentAzureAdRoleIndex++

     # Ensure we are still connected to Microsoft Graph
     if (-not (Get-MgUserMe -ErrorAction SilentlyContinue)) {
         Connect-MgGraph -Scopes "RoleManagement.Read.All", "Directory.Read.All"
     }

     $roleDefinition = Get-MgDirectoryRole | Where-Object { $_.DisplayName -eq $roleName }

     if ($roleDefinition) {
         $roleId = $roleDefinition.Id

         # Get users assigned to this role
         $roleAssignments = Get-MgDirectoryRoleAssignment -Filter "roleDefinitionId eq '$roleId'"

         foreach ($assignment in $roleAssignments) {
             $principalId = $assignment.PrincipalId
             $principalDetails = Get-MgUser -UserId $principalId

             if ($principalDetails) {
                 $output += [PSCustomObject]@{
                     GroupName = $roleDefinition.DisplayName
                     MemberName = $principalDetails.UserPrincipalName
                     MemberOfGroup = $roleDefinition.DisplayName
                     Source = "Azure AD"
                 }
             }
         }
         Write-Output "Completed processing Azure AD role: $roleName"
     } else {
         Write-Warning "Azure AD role '$roleName' not found."
     }

     Write-Progress -Activity "Processing Azure AD Roles" -Status "Processing $roleName" -PercentComplete (($currentAzureAdRoleIndex / $totalAzureAdRoles) * 100)
 }

 # Export to CSV
 $output | Export-Csv -Path "ADGroupMembers.csv" -NoTypeInformation

 Write-Output "CSV report generated: ADGroupMembers.csv"