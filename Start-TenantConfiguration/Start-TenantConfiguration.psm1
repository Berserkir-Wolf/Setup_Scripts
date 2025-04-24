# --------------------------------------------------------
# Script: Configure-365Tenant.psm1
# Author: Dyson Parkes, ClarityIT
# Date: 16/04/2025 14:00:00
# Keywords: Configuration Scripts
# comments: 
# --------------------------------------------------------



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

function Start-TenantConfiguration {
#region Parameters (domain)
param(
[Parameter(Mandatory=$true, HelpMessage="What domain is this for?")][string]$Domain
# The drive letter of the windows installer
)
#endregion
# Import Exchange Online module
Import-Module ExchangeOnlineManagement
# Connect to exchange online
Connect-ExchangeOnline
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
}

Export-ModuleMember -Function *
Export-ModuleMember -Variable *