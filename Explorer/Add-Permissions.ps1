# --------------------------------------------------------
# Script: Add-Permissions.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 10/07/2025 09:00:00
# Keywords: File Permissions
# Version: 1.0
# Comments: 
# Description: This script gets the contents of a specified directory and adds permissions to the files and folders for a specified user or group.
# --------------------------------------------------------
<#
.SYNOPSIS
    This script retrieves the contents of a specified directory and adds permissions to the files and folders for a specified user or group. 
#>

Param
(
    [Parameter(Mandatory=$true, HelpMessage="What directory do you want to get the contents of?")][string]$DirectoryPath,
    [Parameter(Mandatory=$true, HelpMessage="What user or group do you want to add permissions for?")][string]$UserOrGroup,
    [Parameter(Mandatory=$false, HelpMessage="What permission level do you want to set? (ie FullControl, ReadAndExecute, Modify)")][string]$PermissionLevel = "FullControl",
    [Parameter(Mandatory=$false, HelpMessage="Should the script log errors to a file?")][switch]$LogErrors = $true,
    [Parameter(Mandatory=$false, HelpMessage="Where should the script log to?")][string]$ErrorLogFile = "C:\Logs\Add-Permissions-Errors.log"

)
# Check if the specified directory exists
if (-Not (Test-Path -Path $DirectoryPath)) {
    Write-Host "The specified directory does not exist: $DirectoryPath" -ForegroundColor Red
    exit 1
}
# Verify that the user or group exists
try {
    $userOrGroupExists = Get-LocalUser -Name $UserOrGroup -ErrorAction Stop
} catch {
    try {
        $userOrGroupExists = Get-LocalGroup -Name $UserOrGroup -ErrorAction Stop
    } catch {
        try {
            $userOrGroupExists = Get-ADUser -Identity $UserOrGroup -Ser -ErrorAction Stop
        }
        catch {
            try {
                $userOrGroupExists = Get-ADGroup -Identity $UserOrGroup -ErrorAction Stop
            }
            catch {
                Write-Host "The specified user or group does not exist: $UserOrGroup" -ForegroundColor Red
                exit 1
            }
        }
    }
}
# Get the contents of the specified directory
$items = Get-ChildItem -Path $DirectoryPath -Recurse -ErrorAction SilentlyContinue
if ($items.Count -eq 0) {
    Write-Host "No items found in the specified directory: $DirectoryPath" -ForegroundColor Yellow
    exit 0
}
# Loop through each item in the directory
foreach ($item in $items) {
    try {
        # Get the current ACL for the item
        $acl = Get-Acl -Path $item.FullName
        
        # Create a new rule for the specified user or group
        $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserOrGroup, $PermissionLevel, "Allow")
        
        # Add the rule to the ACL
        $acl.AddAccessRule($rule)
        
        # Set the updated ACL back to the item
        Set-Acl -Path $item.FullName -AclObject $acl
    } catch {
        if ($LogErrors) {
            $_ | Out-File -FilePath $ErrorLogFile -Append
        }
        Write-Host "Failed to add permissions for $UserOrGroup to $($item.FullName): $_" -ForegroundColor Red
        # Try to take ownership of the item if permission changes fail
        try {
            $owner = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
            $acl.SetOwner([System.Security.Principal.NTAccount]$owner)
            Set-Acl -Path $item.FullName -AclObject $acl
            Write-Host "Ownership of $($item.FullName) changed to $owner" -ForegroundColor Yellow
                # Get the current ACL for the item
                $acl = Get-Acl -Path $item.FullName
                
                # Create a new rule for the specified user or group
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule($UserOrGroup, $PermissionLevel, "Allow")
                
                # Add the rule to the ACL
                $acl.AddAccessRule($rule)
                
                # Set the updated ACL back to the item
                Set-Acl -Path $item.FullName -AclObject $acl

        } catch {
            Write-Host "Failed to take ownership of $($item.FullName): $_" -ForegroundColor Red
        }
    }
}