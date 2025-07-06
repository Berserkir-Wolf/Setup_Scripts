<#
# --------------------------------------------------------
# Script:Get-UserOneDrives.ps1
# Author: Dyson Parkes, ClarityIT
# Date: 01/07/2025 14:00:00
# Keywords: Information Gathering
# Version: 1.1
# Comments: 
# Description: This script queries Microsoft Graph to confirm each users personal 
# OneDrive URL in the connected Azure Tenant for use with the Sharepoint Migration Tool.
# --------------------------------------------------------
#>
Param
(
    [Parameter(Mandatory=$false, HelpMessage="Where is the list of users to retrieve URLs for?")][string]$InFile = "D:\Setup_Tools\Users.csv",
    [Parameter(Mandatory=$false, HelpMessage="Where do you want to export the OneDrive URLs to?")][string]$OutFile = "D:\Setup_Tools\UserOneDrives.csv",
    [Parameter(Mandatory=$false, HelpMessage="Should a new Microsoft Graph session be created for this query?")][switch]$CreateSession,
    [Parameter(Mandatory=$false, HelpMessage="What Tenant ID should be connected to? (Client ID and Certificate required for this method)")][string]$TenantId,
    [Parameter(Mandatory=$false, HelpMessage="What App ID should be used for this connection? (Tenant ID and Certificate required for this method)")][string]$ClientId,
    [Parameter(Mandatory=$false, HelpMessage="What certificate should be used for this connection? (Tenant and Client ID required for this method)")][string]$CertificateThumbprint
)

$Users = Import-Csv -Path $InFile
Function Connect_MgGraph
{
  #Check for module installation
  $MsGraphBetaModule =  Get-Module Microsoft.Graph.Beta -ListAvailable
  if($null -eq $MsGraphBetaModule){ 
      Write-host "Important: Microsoft Graph Beta module is unavailable. It is mandatory to have this module installed in the system to run the script successfully." 
      $confirm = Read-Host Are you sure you want to install Microsoft Graph Beta module? [Y] Yes [N] No  
      if($confirm -match "[yY]"){ 
          Write-host "Installing Microsoft Graph Beta module..."
          Install-Module Microsoft.Graph.Beta -Scope CurrentUser -AllowClobber
          Write-host "Microsoft Graph Beta module is installed in the machine successfully" -ForegroundColor Magenta 
      }else{ 
          Write-host "Exiting. `nNote: Microsoft Graph Beta module must be available in your system to run the script" -ForegroundColor Red
          Exit 
      } 
  }
  #Disconnect Existing MgGraph session
  if($CreateSession.IsPresent){
    Disconnect-MgGraph
  }
  #Connecting to MgGraph beta
  Write-Host Connecting to Microsoft Graph...
  if(($TenantId -ne "") -and ($ClientId -ne "") -and ($CertificateThumbprint -ne "")){  
    Connect-MgGraph  -TenantId $TenantId -AppId $ClientId -CertificateThumbprint $CertificateThumbprint 
  }else{
    Connect-MgGraph -Scopes "files.readwrite.all","Sites.readwrite.all","directory.readwrite.all","user.readwrite.all"
  }
}
Connect_MgGraph
if((Get-MgContext) -ne ""){
  Write-Host Connected to Microsoft Graph PowerShell using (Get-MgContext).Account account -ForegroundColor Yellow
  $MGGraphConnected = $true
}


if($MGGraphConnected){
    $outfile = $OutFile
    if (Test-Path $outfile) {  
        Write-Host "Output file already exists. Deleting it..." -ForegroundColor Yellow
        Remove-Item $outfile -Force
    }
    foreach ($user in $Users) {
        $userPrincipalName = $user.Mail
        $userObject = Get-MgUser -UserId $userPrincipalName
        if ($userObject) {
            $userOneDrive = Get-MgUserDefaultDrive -UserId $userObject.id
            $oneDriveWebUrl = $userOneDrive.webUrl

            Write-Host "OneDrive WebURL for ${userPrincipalName}: $oneDriveWebUrl"
            $user.OneDriveURL = $oneDriveWebUrl

        Add-Content -Path $outfile -Value "$userPrincipalName,$oneDriveWebUrl"
        } else {
        Write-Host "User not found: $userPrincipalName"
        }
    }
}
