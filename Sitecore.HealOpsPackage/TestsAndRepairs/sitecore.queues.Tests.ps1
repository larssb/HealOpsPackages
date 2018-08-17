<#
    | INFO |
    - These tests should only run on the Sitecore CM server. As it will get stats on each server in the architecture
    of your Sitecore setup. So there is no need to execute on each and every server.

    - There is no Repairs.ps1 file accompanying this file as you shouldn't e.g. just flush the queues. So the purpose is to get out stats.
#>
# Import the Get-SitecoreQueueStats function
. $PSScriptRoot/../Private/Get-SitecoreQueueStats.ps1
Describe "sitecore.eventqueue.total" {
    <#
        - Tests whether the amount of jobs in the Process and Event queues is above the recommended limit.
    #>
    It "Get out the number " {
        #
        'TEST_CODE_HERE'
        $global:failedTestResult =

        # Determine the result of the test
        $global:passedTestResult =
        $ | Should .....
    }
}

Describe "" {

}

<#
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
#>