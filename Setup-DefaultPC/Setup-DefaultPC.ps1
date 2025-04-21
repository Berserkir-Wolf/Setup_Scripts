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
        [Parameter(Mandatory=$true, HelpMessage="What manufacturer is this PC?")][string]$Manufacturer = ""
    )
    # Check if the script is running with administrative privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script requires administrative privileges. Please run it as an administrator."
        exit
    }
    Remove-ManufacturerBloat -Manufacturer $Manufacturer
    Remove-MicrosoftBloat
}

Remove-ManufacturerBloat{
    param(
        [string]$Manufacturer = ""
    )
    # Remove manufacturer bloatware based on the specified manufacturer
    switch ($Manufacturer) {
        "HP" {
            Write-Host "Removing HP bloatware..."
            # Add commands to remove HP bloatware here
        }
        "Lenovo" {
            Write-Host "Removing Lenovo bloatware..."
            # Add commands to remove Lenovo bloatware here
        }
        "Generic"{
            Write-Host "Removing generic bloatware..."
            # Add commands to remove generic bloatware here
        }
        default {
            Write-Host "No manufacturer specified or unsupported manufacturer."
        }
    }
}

Remove-MicrosoftBloat{
    param(
        [string[]]$MicrosoftBloat = @("Xbox","Mail","Weather","News","Sports","Money","Maps","Movies & TV")
    )
    ForEach($Bloatware in $MicrosoftBloat) {
        Write-Host "Removing $Bloatware..."
        # Remove the specified Microsoft bloatware
        Get-AppxPackage -Name $BloatwareBloat -AllUsers | ForEach-Object {
            Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
        }
    }
        Write-Host "Microsoft bloatware removal completed."
    }

    Set-LanguageOptions{
        param(
            [string]$Language = "en-NZ",
            [string]$Region = "NZ"
        )
        # Set the language and region options
        Set-WinUserLanguageList -Language $Language -Force
        Set-WinSystemLocale -SystemLocale $Region
        Set-Culture -CultureInfo $Language
    }