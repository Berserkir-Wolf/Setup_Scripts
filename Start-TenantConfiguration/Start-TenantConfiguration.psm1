# --------------------------------------------------------
# Script: Configure-365Tenant.psm1
# Author: Dyson Parkes, ClarityIT
# Date: 16/04/2025 14:00:00
# Keywords: Configuration Scripts
# comments: 
# --------------------------------------------------------

function Start-TenantConfiguration {
    #region Parameters (domain)
    param(
    [Parameter(Mandatory=$true, HelpMessage="What domain is this for?")][string]$Domain,
    [Parameter(Mandatory=$false, HelpMessage="Configure default Exchange rules?")][bool]$ExchangeRules = $true,
    [Parameter(Mandatory=$false, HelpMessage="Configure default Sharepoint folder?")][bool]$Sharepoint = $false
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
        Write-Host "Configuring Exchange Online rules for $Domain"
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
        }
        #endregion
        #region Configure Exchange Rules
        Write-Host "Configuring AntiSpoofing Rule for $Domain"
        Set-AntiSpoofing -domain $Domain
        
        Write-Host "Configuring Blocklist Rule for $Domain"
        Set-Blocklist -domain $Domain
        
        Write-Host "Configuring AntiSpam Rule for $Domain"
        Set-AntiSpam -domain $Domain
        
        Write-Host "Configuring External Sender Disclaimer Rule for $Domain"
        Set-ExternalDisclaimer -domain $Domain
        
        Write-Host "Configuring Blocked Attachment Rule for $Domain"
        Set-AttachmentFilter
        #endregion
        #region Disconnect from Exchange Online
        Disconnect-ExchangeOnline -Confirm:$false
        #endregion
    } else {
        Write-Host "Skipping Exchange Online configuration."
    }
    #endregion
    #region Sharepoint Tasks
    Write-Host "Configuring Sharepoint Tenant for $Domain"
    
    #endregion
    }

#region Configure AntiSpoofing Rule
function Set-AntiSpoofing {
param(
[string[]]$Domain
)
New-TransportRule -Name "Anti-Spoofing" -Priority 0 -Mode Enforce -SenderAddressLocation Header -SenderDomainIs $domain -RejectMessageEnhancedStatusCode 5.7.1 -RejectMessageReasonText "Block email due to the unsafe anti-spoofing rule" -FromScope NotInOrganization -StopRuleProcessing $false
}
#endregion
#region Configure Blocklist Rule
function Set-Blocklist {
param(
[string[]]$Domain
)
New-TransportRule -Name 'Block List' -Priority 1 -Mode Enforce -DeleteMessage $true -SenderAddressLocation Header -RecipientAddressType Resolved -FromAddressContainsWords {} -Enabled $false
}
#endregion
#region Configure AntiSpam Rule
function Set-AntiSpam {
param(
[string[]]$Domain
)
New-TransportRule -Name 'Spam' -Priority 2 -Mode Enforce -SenderAddressLocation Header -RecipientAddressType Resolved -FromAddressContainsWords 'postmaster','mailer-daemon' -DeleteMessage $true
}
#endregion

#region Configure External Sender Disclaimer Rule
function Set-ExternalDisclaimer {
param(
[string[]]$Domain
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

Export-ModuleMember -Function *
Export-ModuleMember -Variable *