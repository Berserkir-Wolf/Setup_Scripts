# Setup_Scripts

A group of system configuration tools written in whatever language is most relevant for them.

A lot of them are able to be used directly, via using the raw url of the script in an "Invoke-RestMethod" command, piped to Invoke-Expression.  
`irm 'path-to-file' | iex`  
For others, it is recommended to download and run the file as they support parameters.

| Script | Command | Wiki Page |
| ---- | ---- | ---- |
| Set-DefaultProfile | `irm https://github.com/Berserkir-Wolf/Setup_Scripts/raw/refs/heads/main/Set-DefaultProfile/Set-DefaultProfile.ps1 \| iex` | [Wiki Link](https://github.com/Berserkir-Wolf/Setup_Scripts/wiki/Set-DefaultProfile)
| Start-PCSetup | `irm https://raw.githubusercontent.com/Berserkir-Wolf/Setup_Scripts/refs/heads/main/Start-PCSetup/Start-PCSetup.ps1 \| iex` | [Wiki Link](https://github.com/Berserkir-Wolf/Setup_Scripts/wiki/Start-PCSetup) |
| Start-TenantConfiguration | `irm https://raw.githubusercontent.com/Berserkir-Wolf/Setup_Scripts/refs/heads/main/Start-TenantConfiguration/Start-TenantConfiguration.psm1 \| iex` | [Wiki Link](https://github.com/Berserkir-Wolf/Setup_Scripts/wiki/Start-TenantConfiguration) |
| Match-AzureAD | _Use downloaded file with parameters_ | [Wiki Link](https://github.com/Berserkir-Wolf/Setup_Scripts/wiki/Match-AzureAD) |
| Remove-DomainFederation | `irm https://raw.githubusercontent.com/Berserkir-Wolf/Setup_Scripts/refs/heads/main/Snippets/Remove-DomainFederation.ps1 \| iex` | [Wiki Link](https://github.com/Berserkir-Wolf/Setup_Scripts/wiki/Remove-DomainFederation) |
| Get-MFAUserMethods | `irm https://raw.githubusercontent.com/Berserkir-Wolf/Setup_Scripts/refs/heads/main/Snippets/Get-MFAUserMethods.ps1 \| iex` | [Wiki Link](https://github.com/Berserkir-Wolf/Setup_Scripts/wiki/Get-MFAUserMethods) |
| Move-WifiNetworks | `irm https://raw.githubusercontent.com/Berserkir-Wolf/Setup_Scripts/refs/heads/main/Snippets/Move-WifiNetworks.ps1 \| iex` | [Wiki Link](https://github.com/Berserkir-Wolf/Setup_Scripts/wiki/Move-WifiNetworks) |

More detailed descriptions of how to use these tools will be found in the [wiki](https://github.com/Berserkir-Wolf/Setup_Scripts/wiki) (which will always be in an _under construction_ state, given I will inevitably be tweaking or adding things to the scripts).

