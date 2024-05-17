try {
    # Import the Active Directory module
    Import-Module ActiveDirectory -ErrorAction Stop
    
    # Import the ImportExcel module
    Import-Module ImportExcel -ErrorAction Stop

    # Set the threshold for inactivity in days
    $thresholdDays = 30

    # Get the current date and calculate the threshold date
    $currentDate = Get-Date
    $thresholdDate = $currentDate.AddDays(-$thresholdDays)

    # Initialize an empty array to hold the report data
    $report = @()

    # Get all users from Active Directory, filtering by objectClass to ensure only user objects are retrieved
    $users = Get-ADUser -Filter { objectClass -eq "user" } -Property DisplayName, LastLogonDate, Enabled -ErrorAction Stop

    foreach ($user in $users) {
        try {
            # Determine user status
            $status = if ($user.Enabled) { "Active" } else { "Disabled" }

            # Check if LastLogonDate property is available and not null
            if ($null -ne $user.LastLogonDate) {
                # Compare the LastLogonDate with the threshold date
                if ($user.LastLogonDate -lt $thresholdDate) {
                    # If the user has not logged in within the threshold, add them to the report
                    $report += [PSCustomObject]@{
                        DisplayName   = $user.DisplayName
                        LastLogonDate = $user.LastLogonDate
                        Status        = $status
                    }
                }
            } else {
                # If LastLogonDate is null, consider the user as never logged in
                $report += [PSCustomObject]@{
                    DisplayName   = $user.DisplayName
                    LastLogonDate = "Never Logged In"
                    Status        = $status
                }
            }
        } catch {
            Write-Warning "Failed to process user: $($user.DisplayName). Error: $_"
        }
    }

    # Output the report to console
    if ($report.Count -gt 0) {
        $report | Format-Table -AutoSize
    } else {
        Write-Output "All users have logged in within the last $thresholdDays days."
    }

    # Export the report to an Excel file
    $excelPath = "D:\Automation\Report\report.xls"
    $report | Export-Excel -Path $excelPath -WorksheetName "User Report" -AutoSize

    Write-Output "Report successfully exported to $excelPath"

} catch {
    Write-Error "An error occurred: $_"
}