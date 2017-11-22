#Requires -Module WebAdministration
Describe "iis.resource.logs" {
    <#
        - Test for IIS logs over 30days
    #>
    It "No logs should be over 30 days old" {
        # Get logfile dirs
        $tempArrayListForLogFileDirs = [System.Collections.ArrayList]::new()
        foreach($WebSite in $(get-website)) {
            $logFileDirs = "$($Website.logFile.directory)\w3scv$($website.id)".replace("%SystemDrive%",$env:SystemDrive)

            # Add it to the temp. collection
            $tempArrayListForLogFileDirs.Add($logFileDir)
        }

        # Iterate over dirs and check for count of logs >= 30
        foreach ($logfileDir in $logFileDirs) {
            # Get logfils that are >= 30 days
            $files = (Get-ChildItem -Path $logfileDir -Recurse -File -Force | Where-Object { $_.LastWriteTime -le (Get-Date).AddDays(-30) }).count

            if ($files -gt 0) {
                # No need to continue the iteration
                break
            }
        }

        # Assert
        $global:assertionResult = $files
        $files | Should BeLessThan 1
    }
}