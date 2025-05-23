# PowerAD

PowerShell Scripts for Hybrid Active Directory Reconnaissance and Incident Response

## Overview

PowerAD is a collection of PowerShell scripts designed to help security professionals, system administrators, and incident responders work with Active Directory and Microsoft Entra ID (formerly Azure AD) environments. These scripts assist with:

- Identifying and monitoring Tier Zero objects in Active Directory
- Extracting and analysing group memberships
- Responding to security incidents involving privileged accounts and computers
- Visualising organisational hierarchies
- Connecting to Microsoft Graph API securely

## Prerequisites

Most scripts in this collection require:

- PowerShell 5.1 or higher
- Active Directory PowerShell module (`Import-Module ActiveDirectory`)
- Appropriate permissions to query AD objects and replication metadata
- For Microsoft Graph/Entra ID scripts:
  - Microsoft.Graph.Authentication module
  - Microsoft.Graph.DirectoryObjects module
  - Microsoft.PowerShell.SecretManagement module

## Scripts

### Respond-ADTierZeroGroupChanges.ps1

**Purpose**: Monitors and reports on recent changes to Tier Zero Active Directory groups.

**Details**:
- Utilises replication metadata to identify recent changes to the 'member' attribute
- Works with predefined list of critical security groups
- Exports results to CSV and displays in console

**Usage**:
```powershell
.\Respond-ADTierZeroGroupChanges.ps1
```

### Respond-ADTierZeroComputerChanges.ps1

**Purpose**: Tracks changes to critical Tier Zero computer objects in Active Directory.

**Details**:
- Monitors key computer attributes including last logon, password changes, and group memberships
- Identifies potential security issues with domain controllers and other critical servers
- Outputs findings to CSV and console display

**Usage**:
```powershell
.\Respond-ADTierZeroComputerChanges.ps1
```

### Export-ADTierZeroObjects.ps1

**Purpose**: Extracts all user and computer objects with Tier Zero access and their group dependencies.

**Details**:
- Identifies all members of critical security groups
- Maps dependencies between privileged accounts and their group memberships
- Provides comprehensive data for privilege escalation path analysis
- Exports data to CSV format for further analysis

**Usage**:
```powershell
.\Export-ADTierZeroObjects.ps1
```

### Export-ADOUHierarchy.ps1

**Purpose**: Creates a map of your Active Directory organisational unit (OU) structure.

**Details**:
- Retrieves the complete OU hierarchy with parent-child relationships
- Calculates object counts within each OU
- Exports data in a format suitable for visualisation tools like Lucidchart
- Provides insights into AD organisational structure

**Usage**:
```powershell
.\Export-ADOUHierarchy.ps1
```

### Export-ADGroupMemberships.ps1

**Purpose**: Searches for and exports detailed information about specific AD groups.

**Details**:
- Interactive prompt for searching multiple groups by name pattern
- Retrieves group descriptions, notes, members, and OU path
- Creates separate CSV files for each search string
- Handles large group memberships gracefully

**Usage**:
```powershell
.\Export-ADGroupMemberships.ps1
```

### Export-EntraTierZeroObjects.ps1

**Purpose**: Identifies privileged roles and their members in Microsoft Entra ID.

**Details**:
- Connects to Microsoft Graph API using secure authentication
- Retrieves members of critical Entra ID roles (formerly Azure AD roles)
- Includes Global Administrator, Privileged Authentication Administrator, and other high-privilege roles
- Displays role memberships in console output

**Usage**:
```powershell
.\Export-EntraTierZeroObjects.ps1
```

### Connect-MicrosoftGraphApp.ps1

**Purpose**: Provides a secure template for connecting to Microsoft Graph API as an application.

**Details**:
- Demonstrates secure secret management using Microsoft.PowerShell.SecretManagement
- Uses client credentials flow for application authentication
- Provides foundation for building Microsoft Graph API scripts
- Includes detailed setup instructions in comments

**Usage**:
```powershell
# First set up secrets:
Set-Secret -Name ClientId -Secret "<your-client-id>"
Set-Secret -Name TenantId -Secret "<your-tenant-id>"
Set-Secret -Name ClientSecret -Secret "<your-client-secret>"

# Then run:
.\Connect-MicrosoftGraphApp.ps1
```

## Use Cases

- **Incident Response**: Quickly identify changes to critical groups and computers
- **Security Assessment**: Map privileged access paths and identify excessive permissions
- **Documentation**: Export AD structure for documentation and visualisation
- **Compliance**: Track and report on privileged access for audit purposes
- **Migration Planning**: Understand your AD structure before cloud migrations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Licence

This project is licensed under the MIT Licence - see the LICENCE file for details.
