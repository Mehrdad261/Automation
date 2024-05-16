function check_for_updates {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script must be run as an administrator."
        Start-Sleep -Seconds 5
        Exit 1
    }
    
    $searcher = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $searcher.CreateUpdateSearcher()

    # Check current execution policy
    $currentExecutionPolicy = Get-ExecutionPolicy
    Write-Host "Current Execution Policy: $currentExecutionPolicy"

    # Change execution policy to RemoteSigned if it's not already set
    if ($currentExecutionPolicy -ne "RemoteSigned") {
        try {
            Set-ExecutionPolicy RemoteSigned -Scope Process -Force
            Write-Host "Changing policy changed to RemoteSigned."
        } catch {
            Write-Host "Failed to change execution policy. Error: $_"
            Exit 1
        }
    }
    
    Write-Host "Searching for new updates..."
    $searchResult = $updateSearcher.Search("IsInstalled=0")
    
    Write-Host ("Found {0} updates" -f $searchResult.Updates.Count)
    
    if ($searchResult.Updates.Count -gt 0) {
        Write-Host "New updates available:"
        $updateList = @()
        foreach ($update in $searchResult.Updates) {
            $truncatedTitle = if ($update.Title.Length -gt 50) { $update.Title.Substring(0, 47) + "..." } else { $update.Title }
            $truncatedDescription = if ($update.Description.Length -gt 50) { $update.Description.Substring(0, 47) + "..." } else { $update.Description }

            $updateInfo = [PSCustomObject]@{
                KBArticleIDs = ($update.KBArticleIDs -join ", ")
                Title        = $truncatedTitle
                Description  = $truncatedDescription
            }
            $updateList += $updateInfo
        }

        $updateList | Format-Table -AutoSize
        
        $downloader = $searcher.CreateUpdateDownloader()
        $downloader.Updates = $searchResult.Updates
        
        try {
            Write-Host "Downloading updates..."
            $downloader.Download()
            Write-Host "Updates downloaded successfully. If you'd like to install them, please run Install_update..."
        } catch {
            Write-Host "Failed to download updates. Error: $_"
        }
    } else {
        Write-Host "No updates available."
    }

    # Restore previous execution policy
    if ($currentExecutionPolicy -ne "RemoteSigned") {
        try {
            Set-ExecutionPolicy $currentExecutionPolicy -Scope Process -Force
            Write-Host "Execution policy restored to $currentExecutionPolicy."
        } catch {
            Write-Host "Failed to restore previous execution policy. Error: $_"
        }
    }
    
    Start-Sleep -Seconds 10
}

check_for_updates