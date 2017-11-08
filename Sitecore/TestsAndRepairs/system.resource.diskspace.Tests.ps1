Describe "system.resource.diskspace" {
    <#
        - Tests that there is more than 10GB left on all drives on the system
    #>
    It "All available drives should have 10GB or more diskspace left" {
        # Get the local drives
        $localDrives = get-wmiobject win32_volume | Where-Object { $_.DriveType -eq 3 -and $_.SystemVolume -eq $false }
        
        foreach ($drive in $localDrives) {
            # Calculate free space available
            $freeSpaceOkay = $drive.FreeSpace/1GB -gt 10
            
            if($freeSpaceOkay -eq $false) {
                # We need to alert / remediate
                $result = 0
            
                # Break as there is no need to continue iterating
                break
            } else {
                $result = 1
            }
        }

        # Determine the result of the test
        $global:assertionResult = $result
        $result | Should Be 1
    }
}