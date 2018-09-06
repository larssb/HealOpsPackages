# Import the Get-wFreeDiskspace function
. $PSScriptRoot/../Private/Get-wFreeDiskspace.ps1

# Retrieve a collection for storing Metrics
$MetricsCollection = Out-MetricsCollectionObject

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
                $Result = $false

                # Break as there is no need to continue iterating. A problem was found.
                break
            } else {
                $Result = $true
            }
        }

        # Store the metrics
        $enumerator = $freespace.GetEnumerator()
        foreach ($entry in $enumerator) {
            # Get a MetricItem
            $MetricItem = Out-MetricItemObject
            $MetricItem.Metric = "wsystem.resource.diskspace"
            $MetricItem.MetricData = @{
                "Drive" = $entry.Key
                "Value" = $entry.Value
            }

            # Add the metric to the MetricsCollection
            $MetricsCollection.Add($MetricItem)
        }

        # Set global report variables
        $global:passedTestResult = $MetricsCollection
        $global:failedTestResult = $MetricsCollection

        # Determine the Result of the test
        $Result | Should Be $true
    }
}