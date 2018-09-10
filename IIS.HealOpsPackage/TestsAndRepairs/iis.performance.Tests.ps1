# Retrieve a collection for storing Metrics
$MetricsCollection = Out-MetricsCollectionObject

Describe "iis.performance.cpu" {
    <#
        - Test that the W3WP is not CPU exhausting the server
    #>
    It "W3WP IIS process usage should be below 80% over a 5 minute period" {
        # Do the measurement
        $CPUPercentMeasures = Get-Counter -ComputerName localhost -Counter '\Process(w3wp)\% Processor Time' -MaxSamples 300 -SampleInterval 1 `
        | Select-Object -ExpandProperty countersamples `
        | Select-Object -Property instancename,@{L='CPU';E={($_.Cookedvalue/100).toString('P')}}

        # Collection for containing sorted CPU percentage measures
        $CPUPercentages = @{}
        foreach ($Measure in $CPUPercentMeasures) {
            # Remove "%" from the output
            [float]$CPUPercentage = $Measure.cpu -replace "%","" -replace ",","."

            # Add the CPU percentage to a collection for sorting
            $randomKey = Get-Random
            $CPUPercentages.Add($randomKey,$CPUPercentage)
        }

        # Sort the collection
        $CPUPercentagesEnumerator = $CPUPercentages.GetEnumerator()
        $SortedCPUPercentages = $CPUPercentagesEnumerator | Sort-Object Value

        # Find the median
        $CPUPercentageMedian = $SortedCPUPercentages.Get(150) # 150 is our median number as we are doing 300 samples with Get-Counter.

        # Get a MetricItem
        $MetricItem = Out-MetricItemObject
        $MetricItem.Metric = "iis.performance.cpu"
        $MetricItem.MetricData = @{
            "Value" = $CPUPercentageMedian.Value
        }

        # Add the metric to the MetricsCollection
        $MetricsCollection.Add($MetricItem)

        # Set global report variables
        $global:passedTestResult = $MetricsCollection
        $global:failedTestResult = $MetricsCollection

        <#
            - ASSERT
        #>
        $CPUPercentageMedian.Value | Should BeLessThan 80
    }
}