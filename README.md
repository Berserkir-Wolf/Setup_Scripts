# Setup_Scripts

A group of system configuration tools written in whatever language is most relevant for them.

## Set-DefaultProfile

This one takes a specified user profile and copies it into the 'Default' profile folder, to get new user profiles to use it as a template.

Functions needed:

- Set Profile
  - Prompt
- Test Profile exists
  - If not, exit/retry?
- Confirm processing
  - If yes:
    - Backup Old Default, confirm success
    - Create new default
    - Copy Files
    - Confirm Success
  - If no:
    - exit
  
## Setup-DefaultHP

This one uninstalls the HP Bloat from a new machine, and sets some default configurations.

Functions needed:

- Uninstall applications
  - HP Wolf Security
  - HP Wolf Security (console)
  - MyHP
  - HP
- Set default language
  - Install NZ Language pack
  - Set as default
  - Remove US
  - Set System Locale to English (New Zealand)
- Install tools?
  - Outlook Classic
  - Acrobat
  - Chrome
  - Teamviewer
    - Place in C:\Users\Public\Downloads
    - Place shortcut in C:\Users\Public\Desktop
  - Office
    - Place shortcuts in C:\Users\Public\Desktop
      - Outlook
      - Word
      - Excel
- Activate desktop icon for "This PC"
- Set Clarity-Wallpaper04 as background