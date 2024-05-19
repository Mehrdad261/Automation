function Install-Updates {
    # Check if the script is running as an administrator
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "This script must be run as an administrator."
        Start-Sleep -Seconds 6
        Exit 1
    }
    
    $installer = New-Object -ComObject Microsoft.Update.Session
    $searcher = $installer.CreateUpdateSearcher()
    
    Write-Host "Searching for new updates..."
    $searchResult = $searcher.Search("IsInstalled=0 and IsHidden=0")
    
    Write-Host ("Found {0} updates" -f $searchResult.Updates.Count)
    
    if ($searchResult.Updates.Count -gt 0) {
        $updatesToInstall = New-Object -ComObject Microsoft.Update.UpdateColl
        
        foreach ($update in $searchResult.Updates) {
            Write-Host ("Adding update: {0}" -f $update.Title)
            $updatesToInstall.Add($update) | Out-Null
        }

        $downloader = $installer.CreateUpdateDownloader()
        $downloader.Updates = $updatesToInstall
        
        Write-Host "Downloading new updates in progress..."
        try {
            $downloader.Download()
            Write-Host "Updates downloaded successfully."
        } catch {
            Write-Host "Failed to download updates. Error: $_"
            return
        }

        $updater = $installer.CreateUpdateInstaller()
        $updater.Updates = $updatesToInstall
        
        Write-Host "Installing updates..."
        $result = $updater.Install()

        switch ($result.ResultCode) {
            0 { Write-Host "Installation not started" }
            1 { Write-Host "Installation in progress" }
            2 { 
                Write-Host "Updates installed successfully"
                
                $restartPrompt = Read-Host "Do you need to restart the computer? (Y/N)"
                if ($restartPrompt.ToLower() -eq 'y') {
                    Restart-Computer
                } else {
                    Write-Host "The system will be updated after you manually restart it..."
                }
            }
            3 { Write-Host "Installation failed" }
            4 { Write-Host "Installation completed with errors" }
            5 { Write-Host "Installation canceled" }
            6 { 
                Write-Host "Installation requires a reboot to complete"
                
                $restartPrompt = Read-Host "Do you want to restart the computer now? (Y/N)"
                if ($restartPrompt.ToLower() -eq 'y') {
                    Restart-Computer
                } else {
                    Write-Host "Please restart the computer to complete the installation."
                }
            }
            default { Write-Host "Unknown installation result: $($result.ResultCode)" }
        }
    } else {
        Write-Host "No updates available to install."
    }
    
    Start-Sleep -Seconds 10
}

Install-Updates
