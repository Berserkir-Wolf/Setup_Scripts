# Setup_Scripts

A group of system configuration tools written in whatever language is most relevant for them.

To use directly, use the raw url of the script in an "Invoke-RestMethod" command, piped to Invoke-Expression.  
`irm 'path-to-file' | iex`  
For some, it is recommended to download and run the file as they support parameters.

| Script | Command |
| ---- | ---- |
| Set-DefaultProfile | `irm https://github.com/Berserkir-Wolf/Setup_Scripts/raw/refs/heads/main/Start-PCSetup/Start-PCSetup.ps1 \| iex` |
| Start-PCSetup | `irm https://raw.githubusercontent.com/Berserkir-Wolf/Setup_Scripts/refs/heads/main/Start-PCSetup/Start-PCSetup.ps1 \| iex` |
| Start-TenantConfiguration | `irm https://raw.githubusercontent.com/Berserkir-Wolf/Setup_Scripts/refs/heads/main/Start-TenantConfiguration/Start-TenantConfiguration.psm1 \| iex` |
| Match-AzureAD | _Use downloaded file with parameters_ |

## Set-DefaultProfile

This one takes a specified user profile and copies it into the 'Default' profile folder, to get new user profiles to use it as a template.

Functions needed:

- [ ] Set Profile
  - [ ] Prompt
- [ ] Test Profile exists
  - [ ] If not, exit/retry?
- [ ] Confirm processing
  - [ ] If yes:
    - [ ] Backup Old Default, confirm success
    - [ ] Create new default
    - [ ] Copy Files
    - [ ] Confirm Success
  - [ ] If no:
    - [ ] exit
  
## Start-PCSetup

This one uninstalls the bloat from a new machine, and sets some default configurations.

Functions needed:

- [ ] Uninstall applications
  - [ ] If HP
    - [ ] HP Wolf Security
    - [ ] HP Wolf Security (console)
    - [ ] MyHP
    - [ ] HP
  - [ ] If Lenovo
    - [ ] ?
- [ ] Set default language
  - [ ] Install NZ Language pack
  - [ ] Set as default
  - [ ] Remove US
  - [ ] Set System Locale to English (New Zealand)
- [ ] Install tools?
  - [ ] Outlook Classic
  - [ ] Acrobat
  - [ ] Chrome
  - [ ] Teamviewer
    - [ ] Place in C:\Users\Public\Downloads
    - [ ] Place shortcut in C:\Users\Public\Desktop
  - [ ] Office
    - [ ] Place shortcuts in C:\Users\Public\Desktop
      - [ ] Outlook
      - [ ] Word
      - [ ] Excel
  - [ ] Default Profile
    - [ ] Sysprep?
- [ ] Activate desktop icon for "This PC"
- [ ] Set Clarity-Wallpaper04 as background

## Configure-365Tenant

### Usage

Functions needed:

- [ ] Exchange
  - [ ]Convert exchange script to function(s), have triggered by parameter
  - [ ] Make antispam a boolean, trigger if true (-spamrules=$true, default $false)
  - [ ] Add extra filters to list
    - [ ] Attachment types etc (-dangerousfiles=$true?, default=$false)
- [ ] Sharepoint
  - [X] Allow setting parameters for tenant name
  - [X] Add function to rename communications folder to work
  - [ ] Add function to create base folder structure from comma separated list via parameter
- [ ] All
  - [ ] Set up functions to activate if relevant parameter not blank
    - [ ] if tenant specified do rename
    - [ ] if folders specified do create
    - [ ] if exchangerules is not false do rules
    - [ ] if additionalalias is true add additional mail addresses
      - [ ] If $add alias, get all mailboxes and add additional mailalias of "smtp:name@$additionalalias" for each.

## Match-AzureAD

This script will add a new UPN suffix to a local Active Directory, update all users in the specified OU to use the new UPN, then take the ObjectGuid from every user in that OU and Base64 encode it before using that encoded string to attach to the matching UPN in Azure/Entra with the converted object as the OnPremisesImmutableID.  
Following this script running, if you install the Entra Connect tool, all users should be hard matched successfully using that ImmutableID.
Note that this is not always necessary, as some directories sync happily on their own - this is only needed on problematic sites where automatic UPN matching fails (more common on legacy sites still using .local domains internally).

### Parameters

- OU  
This is the Organisational Unit to search for local users. It must be entered in full Distinguished Name format (e.g. "OU=Users_Staff,DC=domain,DC=local").
- UPN  
This is the new UPN suffix to attach to the domain and shift all the users to.  
It should be the same as the mailaddress used to sign on in Azure/Entra/365.