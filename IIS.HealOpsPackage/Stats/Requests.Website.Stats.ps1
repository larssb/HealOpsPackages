<#
.DESCRIPTION
    Gets the long running web requests (over 0 secs) on a IIS instance.
.INPUTS
    <none>
.OUTPUTS
    A [System.Collections.Generic.List`1[MetricItem]] type collection, containing the [MetricItem]'s the function collected.
.NOTES
    Set to output [Void] in order to comply with the PowerShell language. Also if [Void] wasn't used, an error would be thrown when invoking the function.
    As the output type [System.Collections.Generic.List`1[MetricItem]] would not be known by PowerShell, when this function is invocated.
.EXAMPLE
    PS C:\> ./Requests.Website.Stats.ps1
    Executes this Stats file.
#>

# Define parameters
[CmdletBinding(DefaultParameterSetName = "Default")]
[OutputType([Void])]
Param()

#############
# Execution #
#############
Begin {
    # Initiate a collection to hold stats data.
    $MetricsCollection = Out-MetricsCollectionObject
}
Process {
    # Get the websites on this IIS server.
    $WebSites = Get-Website | Where-Object { $_.Name -ne "Default Web Site" }

    # Get the number of request, executing for more than 0 sec.
    foreach ($WebSite in $WebSites) {
        # Get the requests
        $WebRequests = $WebSite.applicationPool | Get-WebRequest -AppPool $_

        # Define metric if any long running requests was retrieved
        if ($null -ne $WebRequests) {
            # Get a MetricItem object and populate its properties
            $MetricItem = Out-MetricItemObject
            $MetricItem.Metric = "iis.LongRunning.Requests"
            $MetricItem.MetricData = @{
                "Value" = $WebRequests.Count
            }

            # Add the result to the Stats collection.
            $MetricsCollection.Add($MetricItem)
        }
    }
}
End {
    # Return the gathered stats to caller.
    ,$MetricsCollection
}