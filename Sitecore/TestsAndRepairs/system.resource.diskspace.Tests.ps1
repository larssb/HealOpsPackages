Describe "system.resource.diskspace" {
    <#
        - Test that there is enough diskspace left
    #>
    It "All available drives should have 10GB or more diskspace left" {
        # Get the local drives
        $localDrives = Get-PSDrive -PSProvider FileSystem | Where-Object { $null -eq $_.DisplayRoot };

        # Measure if above freespace threshold
        foreach ($drive in $localDrives) {
            $freeSpaceOkay = $drive.Free/1GB -gt 10;
        }

        # NEED TO DO
            # - sent back int for the metric value
            # - if it fails:
                # yeah what???

        # Determine the result of the test
        $freeSpaceOkay | Should Be $true;
    }
}