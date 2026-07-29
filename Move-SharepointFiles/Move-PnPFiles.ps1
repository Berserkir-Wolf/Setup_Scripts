# ==============================
# CONFIGURATION
# ==============================
$SiteUrl        = "https://contoso.sharepoint.com/sites/sitename" # Full URL of the SharePoint site
$SourceList     = "Recovered Data"   # Name of source document library
$TargetList     = "Transfer"   # Name of target document library
$IndexedField   = "Created"         # Must be indexed in SharePoint
$BatchSize      = 500               # Items per page
$RetryLimit     = 3                 # Max retries on throttling
$SleepSeconds   = 30                # Wait time before retry
$MoveBufferFolder = "C:\Temp\SharePointMoveBuffer"  # Move buffer folder (local temp folder to store files before moving)

# ==============================
# CONNECT TO SHAREPOINT
# ==============================
Write-Host "Connecting to SharePoint Online..." -ForegroundColor Cyan
#Connect-PnPOnline -Url $SiteUrl -Interactive

# ==============================
# MOVE ITEMS IN BATCHES
# ==============================
$RetryCount = 0
$StopLoop   = $false

do {
    try {
        # CAML query to get items in batches using indexed column
        $CamlQuery = @"
<View>
  <Query>
    <Where>
      <IsNotNull>
        <FieldRef Name='$IndexedField' />
      </IsNotNull>
    </Where>
    <OrderBy>
      <FieldRef Name='$IndexedField' Ascending='TRUE' />
    </OrderBy>
  </Query>
  <RowLimit>$BatchSize</RowLimit>
</View>
"@

        # Get items
        $Items = Get-PnPListItem -List $SourceList -Query $CamlQuery -PageSize $BatchSize

        if ($Items.Count -eq 0) {
            Write-Host "No more items to move." -ForegroundColor Green
            $StopLoop = $true
            break
        }

        Write-Host "Processing $($Items.Count) items..." -ForegroundColor Yellow

        foreach ($Item in $Items) {
            $File = Get-PnPFile -Url $Item.FieldValues.FileRef -AsFile -Path $MoveBufferFolder -FileName $Item.FieldValues.FileLeafRef -Force
            Add-PnPFile -Path $File.FullName -Folder $TargetList
            Remove-PnPFile -ServerRelativeUrl $Item.FieldValues.FileRef -Force
        }

        $RetryCount = 0  # Reset retry counter after success
    }
    catch {
        Write-Warning "Error occurred: $($_.Exception.Message)"
        if ($RetryCount -lt $RetryLimit) {
            $RetryCount++
            Write-Host "Retrying in $SleepSeconds seconds... (Attempt $RetryCount of $RetryLimit)" -ForegroundColor Magenta
            Start-Sleep -Seconds $SleepSeconds
            Connect-PnPOnline -Url $SiteUrl -Interactive
        }
        else {
            Write-Error "Max retries reached. Stopping."
            $StopLoop = $true
        }
    }
} while (-not $StopLoop)

Write-Host "Move operation completed." -ForegroundColor Green