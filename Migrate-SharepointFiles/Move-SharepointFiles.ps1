<#
# --------------------------------------------------------
# Script: Move-SharepointFiles.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 26/09/2025 11:59:00
# Keywords: File Management, Sharepoint Migration
# Version: 1.0
# Comments: 
# Description: This script moves files from one SharePoint site to another using PnP PowerShell.
# --------------------------------------------------------
#>
#Requires -Module PnP.PowerShell
Param
(
    [Parameter(Mandatory=$true, HelpMessage="Source SharePoint Site URL")][string]$SourceSiteUrl,
    [Parameter(Mandatory=$true, HelpMessage="Destination SharePoint Site URL")][string]$DestinationSiteUrl,
    [Parameter(Mandatory=$true, HelpMessage="Source Document Library Name")][string]$SourceLibrary,
    [Parameter(Mandatory=$true, HelpMessage="Destination Document Library Name")][string]$DestinationLibrary,
    [Parameter(Mandatory=$false, HelpMessage="Path to log file")][string]$LogFile = "D:\Setup_Tools\SharePointMigration.log"
)
#region Function to log messages
Function Log-Message {
    Param (
        [string]$Message,
        [string]$LogFile
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Add-Content -Path $LogFile -Value $logEntry
}  
#endregion
#region Connect to Source and Destination Sites
Function Connect-Site {
    Param (
        [string]$SiteUrl
    )
    Write-Host "Connecting to $SiteUrl"
    Connect-PnPOnline -Url $SiteUrl -Interactive
    if ($?) {
        Write-Host "Connected to $SiteUrl successfully." -ForegroundColor Green
        Log-Message "Connected to $SiteUrl successfully." $LogFile
    } else {
        Write-Host "Failed to connect to $SiteUrl." -ForegroundColor Red
        Log-Message "Failed to connect to $SiteUrl." $LogFile
        Exit
    }
}
Connect-Site -SiteUrl $SourceSiteUrl
$SourceContext = Get-PnPContext
Connect-Site -SiteUrl $DestinationSiteUrl
$DestinationContext = Get-PnPContext
#endregion
#region Move Files
Function Move-Files {
    Param (
        [string]$SourceLibrary,
        [string]$DestinationLibrary
    )
    Write-Host "Starting file migration from $SourceLibrary to $DestinationLibrary"
    Log-Message "Starting file migration from $SourceLibrary to $DestinationLibrary" $LogFile

    # Get all files from the source library
    $files = Get-PnPListItem -List $SourceLibrary -PageSize 1000 -ScriptBlock { param($items) $items.Context.ExecuteQuery() } | Where-Object { $_.FileSystemObjectType -eq "File" }

    foreach ($file in $files) {
        try {
            $fileUrl = $file.FieldValues.FileRef
            $fileName = $file.FieldValues.FileLeafRef
            Write-Host "Moving file: $fileName"
            Log-Message "Moving file: $fileName" $LogFile

            # Download the file from source
            $tempFilePath = Join-Path -Path $env:TEMP -ChildPath $fileName
            Get-PnPFile -Url $fileUrl -Path $tempFilePath -AsFile -Force

            # Upload the file to destination
            Set-PnPContext -Context $DestinationContext
            Add-PnPFile -Path $tempFilePath -Folder "/$DestinationLibrary" -Overwrite

            # Remove the temporary file
            Remove-Item -Path $tempFilePath -Force

            # Optionally, delete the file from source after moving
            Set-PnPContext -Context $SourceContext
            Remove-PnPListItem -List $SourceLibrary -Identity $file.Id -Recycle

            Write-Host "Successfully moved file: $fileName" -ForegroundColor Green
            Log-Message "Successfully moved file: $fileName" $LogFile
        } catch {
            Write-Host "Error moving file: $fileName. $_" -ForegroundColor Red
            Log-Message "Error moving file: $fileName. $_" $LogFile
        }
    }
    Write-Host "File migration completed."
    Log-Message "File migration completed." $LogFile
}
Move-Files -SourceLibrary $SourceLibrary -DestinationLibrary $DestinationLibrary
#endregion
#region Disconnect from Sites
Disconnect-PnPOnline -Url $SourceSiteUrl
Disconnect-PnPOnline -Url $DestinationSiteUrl
Write-Host "Disconnected from SharePoint sites." -ForegroundColor Green
Log-Message "Disconnected from SharePoint sites." $LogFile
#endregion
