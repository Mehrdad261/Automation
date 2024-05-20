# Before use this code you hould install Excel-module by : " Install-Module -Name ImportExcel -Scope CurrentUser -Force "
try {
    #Active Directory module
    Import-Module ActiveDirectory -ErrorAction Stop
    
    #ImportExcel module
    Import-Module ImportExcel -ErrorAction Stop

    #Set the Period for inactivity in days
    $PeriodDays = 30

    #Get the current date and calculate the Period date
    $currentDate = Get-Date
    $PeriodDate = $currentDate.AddDays(-$PeriodDays)

    #empty array to hold the report data
    $report = @()

    #Get all users from Active Directory, filtering by objectClass to ensure only user objects are retrieved
    $users = Get-ADUser -Filter { objectClass -eq "user" } -Property DisplayName, SamAccountName, LastLogonDate, Enabled -ErrorAction Stop

    foreach ($user in $users) {
        try {
            #Determine user status
            $status = if ($user.Enabled) { "Active" } else { "Disabled" }

            #Check if LastLogonDate property is available and not null
            if ($null -ne $user.LastLogonDate) {
                #Compare the LastLogonDate with the Period date
                if ($user.LastLogonDate -lt $PeriodDate) {
                    #If the user has not logged in within the Period, add them to the report
                    $report += [PSCustomObject]@{
                        DisplayName   = $user.DisplayName #Full Name 
                        Username      = $user.SamAccountName #Username
                        LastLogonDate = $user.LastLogonDate #last logindate 
                        Status        = $status #USer's status (Active, disabled)
                    }
                }
            } else {
                #If LastLogonDate is null, consider the user as never logged in
                $report += [PSCustomObject]@{
                    DisplayName   = $user.DisplayName
                    SamAccountName = $user.SamAccountName  #Include Username 
                    LastLogonDate = "Never Logged In"
                    Status        = $status
                }
            }
        } catch {
            Write-Warning "Failed to process user: $($user.DisplayName). Error: $_"
        }
    }

    # ----------------- Console output report -----------------------
    #if ($report.Count -gt 0) {
    #    $sortedReport = $report | Sort-Object DisplayName 
    #    $sortedReport | Format-Table -AutoSize
    #} else {
    #    Write-Output "All users have logged in within the last $PeriodDays days."
    #}
    #-------------------------------------------------------------------------------

    # folder Path for report
    $folderPath= "C:\Users_Report"
    $excelPath = "$folderPath\report.xls"

    # check for existing folder 
    if (-not (Test-Path -Path $folderPath)){
        New-Item -ItemType Directory -Path $folderPath
    }
     # Export the report to an Excel file
    $sortedReport | Export-Excel -Path $excelPath -WorksheetName "User Report" -AutoSize

    Write-Output "Report successfully exported to $excelPath" 

} catch {
    Write-Error "An error occurred: $_"
}
