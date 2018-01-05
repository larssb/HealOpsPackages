Describe "wsystem.resource.diskspace" {
    <#
        - Tests that there is more than 10GB left on all drives on the system
    #>
    It "All available drives should have 10GB or more diskspace left" {
        # Get the freespace for each drive on the system
        [HashTable]$freespace = Get-wFreeDiskspace

        # Iterate and test
        $enumerator = $freespace.GetEnumerator()
        foreach ($entry in $enumerator) {
            # Test available free space
            $freeSpaceTest = $entry.value -gt 10

            if($freeSpaceTest -eq $false) {
                # We need to alert / remediate
                $result = $false

                # Break as there is no need to continue iterating. A problem was found.
                break
            } else {
                $result = $true
            }
        }

        # Set global report variables
        [HashTable]$global:passedTestResult = $freespace
        [HashTable]$global:failedTestResult = $freespace

        # Determine the result of the test
        $result | Should Be $true
    }
}