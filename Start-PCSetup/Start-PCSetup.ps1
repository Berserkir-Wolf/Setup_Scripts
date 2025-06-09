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

function Start-PCSetup {
    param(
        [Parameter(Mandatory=$true, HelpMessage="What manufacturer is this PC?")][string]$Manufacturer       
    )
    # Check if the script is running with administrative privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script requires administrative privileges. Please run it as an administrator."
        exit
    }
    Remove-ManufacturerBloat -Manufacturer $Manufacturer
    Remove-MicrosoftBloat
    Set-LanguageOptions -Language "en-NZ" -Region "NZ"
}

Remove-ManufacturerBloat{
    param(
        [string]$Manufacturer = ""
    )
    # Remove manufacturer bloatware based on the specified manufacturer
    switch ($Manufacturer) {
        "HP" {
            Write-Host "Removing HP bloatware..."
            Remove-HPBloatware
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
        [string[]]$MicrosoftBloat = @("Microsoft.XboxGameCallableUI","Microsoft.XboxIdentityProvider","Microsoft.XboxSpeechToTextOverlay",
                                        "Microsoft.XboxGameOverlay","Microsoft.XboxApp","Microsoft.Xbox.TCUI","Microsoft.XboxGamingOverlay",
                                        "Microsoft.OutlookforWindows")
    )
    ForEach($Program in $MicrosoftBloat) {
        Write-Host "Removing $Program..."
        # Remove the specified Microsoft bloatware
        Get-AppxPackage -Name $Program -AllUsers | ForEach-Object {
            Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
        }
        Remove-AppxProvisionedPackage -Online -PackageName $Program -ErrorAction Stop
    }
        Write-Host "Microsoft bloatware removal completed."
    }

function Remove-HPBloatware {
    #region Remove HP Support Assistant
    # Remove HP Support Assistant silently
    $HPSAuninstall = "${Env:ProgramFiles(x86)}\HP\HP Support Framework\UninstallHPSA.exe"
    if (Test-Path -Path "HKLM:\Software\WOW6432Node\Hewlett-Packard\HPActiveSupport") {
        try {
            Remove-Item -Path "HKLM:\Software\WOW6432Node\Hewlett-Packard\HPActiveSupport"
            Write-Host "HP Support Assistant regkey deleted $($_.Exception.Message)"
        }
        catch {
            Write-Host "Error retrieving registry key for HP Support Assistant: $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "HP Support Assistant regkey not found"
    }
    if (Test-Path $HPSAuninstall -PathType Leaf) {
        try {
            & $HPSAuninstall /s /v/qn UninstallKeepPreferences=FALSE
            Write-Host "Successfully removed provisioned package: HP Support Assistant silently"
        }
        catch {
            Write-Host "Error uninstalling HP Support Assistant: $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "HP Support Assistant Uninstaller not found"
    }
    #endregion

    #region List of built-in apps to remove
    $UninstallPackages = @(
        "AD2F1837.HPSupportAssistant"
        "AD2F1837.myHP"
        "AD2F1837.HPDesktopSupportUtilities"
    )
    #endregion
    #region List of programs to uninstall
    $UninstallPrograms = @(
        "HP Security Update Service"
        "HP Sure Click"
        "HP Sure Click Security Browser"
    )

    $HPidentifier = "AD2F1837"

    $InstalledPackages = Get-AppxPackage -AllUsers `
    | Where-Object { ($UninstallPackages -contains $_.Name) -or ($_.Name -match "^$HPidentifier") }

    $ProvisionedPackages = Get-AppxProvisionedPackage -Online `
    | Where-Object { ($UninstallPackages -contains $_.DisplayName) -or ($_.DisplayName -match "^$HPidentifier") }

    $InstalledPrograms = Get-Package | Where-Object { $UninstallPrograms -contains $_.Name } | Sort-Object Name -Descending

    #Remove appx provisioned packages - AppxProvisionedPackage
    ForEach ($ProvPackage in $ProvisionedPackages) {
        Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."
        try {
            $Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
            Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
        }
        catch { Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]" }
    }

    #Remove appx packages - AppxPackage
    ForEach ($AppxPackage in $InstalledPackages) {                                        
        Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."
        try {
            $Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
        }
        catch { Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]" }
    }

    #Remove installed programs
    ForEach ($InstalledProgram in $InstalledPrograms) {
        Write-Host -Object "Attempting to uninstall: [$($InstalledProgram.Name)]..."
        try {
            $Null = $InstalledProgram | Uninstall-Package -AllVersions -Force -ErrorAction Stop
            Write-Host -Object "Successfully uninstalled: [$($InstalledProgram.Name)]"
        }
        catch {
            Write-Warning -Message "Failed to uninstall: [$($InstalledProgram.Name)]"
            Write-Host -Object "Attempting to uninstall as MSI package: [$($InstalledProgram.Name)]..."
            try {
                $MSIApp = Get-WmiObject Win32_Product | Where-Object { $_.name -like "$($InstalledProgram.Name)" }
                if ($null -ne $MSIApp.IdentifyingNumber) {
                    Start-Process -FilePath msiexec.exe -ArgumentList @("/x $($MSIApp.IdentifyingNumber)", "/quiet", "/noreboot") -Wait
                }
                else { Write-Warning -Message "Can't find MSI package: [$($InstalledProgram.Name)]" }
            }
            catch { Write-Warning -Message "Failed to uninstall MSI package: [$($InstalledProgram.Name)]" }
        }
    }

    #Try to remove all HP Wolf Security apps using msiexec
    $InstalledWolfSecurityPrograms = Get-WmiObject Win32_Product | Where-Object { $_.name -like "HP Wolf Security*" }
    ForEach ($InstalledWolfSecurityProgram in $InstalledWolfSecurityPrograms) {
        try {
            if ($null -ne $InstalledWolfSecurityProgram.IdentifyingNumber) {
                Start-Process -FilePath msiexec.exe -ArgumentList @("/x $($InstalledWolfSecurityProgram.IdentifyingNumber)", "/quiet", "/noreboot") -Wait
                Write-Host "Attempting to uninstall as MSI package: [$($InstalledWolfSecurityProgram.Name)]..."
            }
            else { Write-Warning -Message "Can't find MSI package: [$($InstalledWolfSecurityProgram.Name)]" }
        }
        catch {
            Write-Warning -Message "Failed to uninstall MSI package: [$($InstalledWolfSecurityProgram.Name)]"
        }
    }
}

# Function to set language and region options
function Set-LanguageOptions{
    param(
        [string]$Language = "en-NZ",
        [string]$Region = "NZ"
    )
    # Set the language and region options
    Set-WinUserLanguageList -Language $Language -Force
    Set-WinSystemLocale -SystemLocale $Region
    Set-Culture -CultureInfo $Language
}
#endregion