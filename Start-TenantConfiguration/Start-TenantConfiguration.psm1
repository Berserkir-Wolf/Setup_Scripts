# --------------------------------------------------------
# Script: Configure-365Tenant.psm1
# Author: Dyson Parkes, ClarityIT
# Date: 16/04/2025 14:00:00
# Keywords: Configuration Scripts
# comments: 
# --------------------------------------------------------

function Start-TenantConfiguration {
    #region Parameters
    param(
    [Parameter(Mandatory=$true, HelpMessage="What domain is this for?")][string]$MailDomain,
    [Parameter(Mandatory=$false, HelpMessage="Configure default Exchange rules?")][bool]$ExchangeRules = $true,
    [Parameter(Mandatory=$false, HelpMessage="Configure Sharepoint?")][bool]$Sharepoint = $false,
    [Parameter(Mandatory=$false, HelpMessage="What is the Sharepoint Admin URL?")][string]$SharepointUrl = "",
    [Parameter(Mandatory=$false, HelpMessage="Configure default Sharepoint site?")][bool]$RenameSharepoint = $false
    )
    #endregion
    #region Check if the script is running with administrative privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script requires administrative privileges. Please run it as an administrator."
        exit
    }
    #endregion
    #region Exchange Tasks
    if($ExchangeRules) {
        Write-Host "Configuring Exchange Online rules for $MailDomain"
        #region Import ExchangeOnlineManagement module if available, install if not
        if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
            Write-Host "Exchange Online Management module is not installed. Installing..."
            Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
            Import-Module ExchangeOnlineManagement
        } else {
            Import-Module ExchangeOnlineManagement
        }
        #endregion
        #region Connect to exchange online and check if the connection was successful
        Connect-ExchangeOnline
        if (-not (Get-ExchangeOnlineConnection)) {
            Write-Host "Failed to connect to Exchange Online. Please check your credentials and try again."
            exit
        } else {
            Write-Host "Connected to Exchange Online successfully."
            #region Configure Exchange Rules
            Write-Host "Configuring AntiSpoofing Rule for $MailDomain"
            Set-AntiSpoofing -domain $MailDomain
            
            Write-Host "Configuring Blocklist Rule for $MailDomain"
            Set-Blocklist -domain $MailDomain
            
            Write-Host "Configuring AntiSpam Rule for $MailDomain"
            Set-AntiSpam -domain $MailDomain
            
            Write-Host "Configuring External Sender Disclaimer Rule for $MailDomain"
            Set-ExternalDisclaimer -domain $MailDomain
            
            Write-Host "Configuring Blocked Attachment Rule for $MailDomain"
            Set-AttachmentFilter
            #endregion
            #region Disconnect from Exchange Online
            Disconnect-ExchangeOnline -Confirm:$false
            #endregion
        }
        #endregion
    } else {
        Write-Host "Skipping Exchange Online configuration."
    }
    #endregion
    #region Sharepoint Tasks
    if($Sharepoint) {
        Write-Host "Connecting to Sharepoint for $SharepointUrl"
        #region Import Sharepoint module if available, install if not
        if (-not (Get-Module -ListAvailable -Name Microsoft.Online.SharePoint.PowerShell)) {
            Write-Host "Microsoft.Online.SharePoint.PowerShell module is not installed. Installing..."
            Install-Module -Name Microsoft.Online.Sharepoint.Powershell -Force -AllowClobber
            Import-Module Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell
        } else {
            Import-Module Microsoft.Online.SharePoint.PowerShell -UseWindowsPowerShell
        }
        #endregion
        #region Connect to Sharepoint Online and check if the connection was successful
        Connect-SpoService -Url "$SharepointUrl"
        if (-not (Get-SPOSite)) {
            Write-Host "Failed to connect to Sharepoint Online. Please check your credentials and try again."
            exit
        } else {
            Write-Host "Connected to Sharepoint Online successfully."
            #region Rename Communication site to Work
            if($RenameSharepoint) {
                Write-Host "Renaming Sharepoint Communication site to Work"
                Rename-SharepointSite
                
            }
            #endregion

            #region Disconnect from Sharepoint Online
            Disconnect-SPOService -Confirm:$false
            #endregion
        }
        #endregion
    } else {
    Write-Host "Skipping Sharepoint setup for $SharepointUrl"
    }
    #endregion
    }

#region Configure AntiSpoofing Rule
function Set-AntiSpoofing {
param(
[string[]]$MailDomain
)
New-TransportRule -Name "Anti-Spoofing" -Priority 0 -Mode Enforce -SenderAddressLocation Header -SenderDomainIs $MailDomain -RejectMessageEnhancedStatusCode 5.7.1 -RejectMessageReasonText "Block email due to the unsafe anti-spoofing rule" -FromScope NotInOrganization -StopRuleProcessing $false
}
#endregion
#region Configure Blocklist Rule
function Set-Blocklist {
param(
[string[]]$MailDomain
)
New-TransportRule -Name 'Block List' -Priority 1 -Mode Enforce -DeleteMessage $true -SenderAddressLocation Header -RecipientAddressType Resolved -FromAddressContainsWords {} -Enabled $false
}
#endregion
#region Configure AntiSpam Rule
function Set-AntiSpam {
param(
[string[]]$MailDomain
)
New-TransportRule -Name 'Spam' -Priority 2 -Mode Enforce -SenderAddressLocation Header -RecipientAddressType Resolved -FromAddressContainsWords 'postmaster','mailer-daemon' -DeleteMessage $true
}
#endregion
#region Configure External Sender Disclaimer Rule
function Set-ExternalDisclaimer {
param(
[string[]]$MailDomain
)
$disclaimer = "<p style='background-color:#FFEB9C; width: 850px; border:2px; border-top-style:solid; border-bottom-style:solid; border-color:#FF0000; padding: 0.3em;'><span style='font-size:9pt;font-family:Arial;color:red'><b>CAUTION:</span></b><span style='font-size:9pt;font-family:Arial;color:black'> This email originated outside your Organisation.  <b>DO NOT CLICK</b> on links, attachments, or action requests unless you recognise the sender and know the content is safe.  &nbsp;⚠  If you think it is suspicious, please <b>REPORT IT</b> to your manager</span>.</p>"
New-TransportRule -Name 'External Sender Disclaimer' -Priority 4 -Mode Enforce -SenderAddressLocation Header -RecipientAddressType Resolved -FromScope NotInOrganization -SentToScope InOrganization -ExceptIfSubjectOrBodyContainsWords "This email originated outside your Organisation" -ApplyHtmlDisclaimerFallbackAction Wrap -ApplyHtmlDisclaimerLocation Prepend -ApplyHtmlDisclaimerText $disclaimer

}
#endregion
#region Configure bad attachment rule
function Set-AttachmentFilter {
New-TransportRule -Name "Block nasty files" -Priority 4 -Mode Enforce -FromScope NotInOrganization -DeleteMessage $true -AttachmentExtensionMatchesWords "*htm*"
}
#endregion

#region Configure Sharepoint Site
function Rename-SharepointSite {
#param(
#) 
$site = Get-SPOSite -Limit All | Where-Object { $_.Title -eq "Communication Site" }
Set-SPOSite  Identity $site.Url -Title "Work"
return $site.Url
}

# These will need to go in order to make a PS1 script rather than a module
Export-ModuleMember -Function *
Export-ModuleMember -Variable *