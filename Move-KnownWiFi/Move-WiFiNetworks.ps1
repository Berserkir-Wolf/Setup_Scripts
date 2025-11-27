<#
# --------------------------------------------------------
# Script: Move-WiFiNetworks.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 28/11/2025 11:59:00
# Keywords: SSID Management, WiFi Migration
# Version: 1.0
# Comments: 
# Description: This script exports WiFi profiles from one machine and allows importing them to another machine.
# --------------------------------------------------------
#>
Param
(
    [Parameter(Mandatory=$false, HelpMessage="Where should the profiles be moved to?")][string]$ProfileFolder = "C:\WiFi"
)

function ExportProfiles {
    Write-Host "Exporting WiFi profiles to $ProfileFolder"
    if (!(Test-Path -Path $ProfileFolder)) {
        New-Item -ItemType Directory -Path $ProfileFolder | Out-Null
    }
    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
        ($_ -split ":")[1].Trim()
    }
    foreach ($profile in $profiles) {
        Write-Host "Exporting profile: $profile"
        netsh wlan export profile name="$profile" folder="$ProfileFolder" key=clear | Out-Null
    }
    Write-Host "Export completed."    
}

function ImportProfiles {
    Write-Host "Importing WiFi profiles from $ProfileFolder"
    $xmlFiles = Get-ChildItem -Path $ProfileFolder -Filter *.xml
    foreach ($file in $xmlFiles) {
        Write-Host "Importing profile from file: $($file.FullName)"
        netsh wlan add profile filename="$($file.FullName)" | Out-Null
    }
    Write-Host "Import completed."
}

# Ask user whether to export or import profiles
$action = Read-Host "Do you want to Export or Import WiFi profiles? (E/I)"
if ($action -eq "E") {
    ExportProfiles
} elseif ($action -eq "I") {
    ImportProfiles
} else {
    Write-Host "Invalid option selected. Please run the script again and choose either E or I."
}