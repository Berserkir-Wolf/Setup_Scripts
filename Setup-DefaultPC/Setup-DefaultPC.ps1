# --------------------------------------------------------
# Script: Setup-DefaultPC.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 22/04/2025 10:00:00
# Keywords: Configuration Scripts
# Comments: 
# Description: This script runs through common configuration options for a new PC.
# It is intended to remove common bloat from a windows PC, and eventually set up a default profile for new users.
# This script is designed to be run with administrative privileges.
# It is recommended to run it in a PowerShell session with elevated permissions.
# --------------------------------------------------------

function Setup-DefaultPC{
    param(
        [string]$HPBloat = "",
        [string]$LenovoBloat = "",
        [string]$MicrosoftBloat = ""
    )
    # Check if the script is running with administrative privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script requires administrative privileges. Please run it as an administrator."
        exit
    }
    
}

