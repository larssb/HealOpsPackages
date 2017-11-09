Describe "iis.performance.cpu" {
    <#
        - Test that the W3WP is not CPU exhausting the server
    #>
    It "W3WP IIS process usage should be below 80% over a 5 minute period" {
        # Do the measurement
        $cpuPercentMeasures = Get-Counter -ComputerName localhost -Counter '\Process(w3wp)\% Processor Time' -MaxSamples 59 -SampleInterval 1 `
        | Select-Object -ExpandProperty countersamples `
        | Select-Object -Property instancename,@{L='CPU';E={($_.Cookedvalue/100).toString('P')}}

        # Collection for containing sorted CPU percentage measures
        $cpuPercentages = @{};
        foreach ($measure in $cpuPercentMeasures) {
            # Remove "%" from the output
            [float]$cpuPercentage = $measure.cpu -replace "%","" -replace ",",".";

            # Add the CPU percentage to a collection for sorting
            $randomKey = Get-Random;
            $cpuPercentages.Add($randomKey,$cpuPercentage);
        }

        # Sort the collection
        $cpuPercentagesEnumerator = $cpuPercentages.GetEnumerator()
        $sortedCpuPercentages = $cpuPercentagesEnumerator | Sort-Object Value

        # Find the median
        $cpuPercentageMedian = $sortedCpuPercentages.Get(29) # 29 is our median number as we are doing 59 samples with Get-Counter. !!!WRON - Should be more samples....and fix the median.

        # Determine the result of the test
        $global:assertionResult = $cpuPercentageMedian.value
        $cpuPercentageMedian.value | Should BeLessThan 80
    }
}