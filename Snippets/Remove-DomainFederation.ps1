# Needs MG-Graph module installed
#Check if the module is installed and install if not
$moduleName = "Microsoft.Graph"
$module = Get-Module -ListAvailable -Name $moduleName
if (-not $module) {
    Write-Host "Module $moduleName is not installed. Installing..."
    Install-Module -Name $moduleName # -Scope CurrentUser
} else {
    Write-Host "Module $moduleName is already installed."
}

# Import the module
Import-Module $moduleName
# Connect to Microsoft Graph with the required permissions
# Note: You may need to adjust the scopes based on your requirements
# The below command will prompt for credentials and ask for consent to the permissions
Connect-MgGraph -Scopes "Directory.Read.All","Domain.ReadWrite.All","Directory.AccessAsUser.All”

# Get the list of domains in your tenant
$domains = Get-MgDomain
# Display the list of domains
$domains | Select-Object Id, IsVerified, Authentication
# Find the domain you want to update (e.g., yourdomain.com)
$domainToUpdate = $domains | Where-Object { $_.Id -like (Read-Host -Prompt "What domain is this for?") }
# Check if the domain is found
if ($domainToUpdate) {
    Write-Host "Found domain: $($domainToUpdate.Id)"
} else {
    Write-Host "Domain not found. Please check the domain name."
}
# Run the command below and confirm that your GoDaddy.com domain says "Federated":

Get-MgDomain

# The below command will update the domain to be "Managed" - replace with your GoDaddy domain:

Update-MgDomain -DomainId $domainToUpdate.ID -Authentication Managed

# Run the below command again to confirm that the GoDaddy domain now says Managed instead of Federated:

Get-MgDomain