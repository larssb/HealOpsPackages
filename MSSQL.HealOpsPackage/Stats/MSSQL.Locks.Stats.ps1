<#
.DESCRIPTION
    LONG_DESCRIPTION
.INPUTS
    <none>
.OUTPUTS
    A [System.Collections.Generic.List`1[StatsItem]] type collection, containing the [StatsItem]'s the function collected.
.NOTES
    Set to output [Void] in order to comply with the PowerShell language. Also if [Void] wasn't used, an error would be thrown when invoking the function.
    As the output type [System.Collections.Generic.List`1[StatsItem]] would not be known by PowerShell, when this function is invocated.
.EXAMPLE
    PS C:\> USAGE_EXAMPLE
    EXPLAIN_THE_EXAMPLE
#>

# Define parameters
[CmdletBinding(DefaultParameterSetName = "Default")]
[OutputType([Void])]
Param()

#############
# Execution #
#############
Begin {
    <#
        - Declare variables, that will be re-used throughout the script.
    #>
    # YOUR_COMMENT

    # Initiate a collection to hold stats data.
    $StatsCollection = Out-StatsCollectionObject
}
Process {
    <#
        - YOUR_COMMENT
    #>
    # Gather locks info on the instance level.
    [Array]$QueryResult = Invoke-DbaSqlQuery -Database "DevOpsTools" -SqlInstance "10.93.1.15" -Query "exec sp_WhoIsActive"

    # Get a StatsItem object and populate its properties
    $StatsItem = Out-StatsItemObject
    $StatsItem.Metric = "mssql.instance.locks"
    $StatsItem.StatsData = @{
        "Value" = $QueryResult.Count
    }

    # Add the result to the Stats collection.
    $StatsCollection.Add($StatsItem)
}
End {
    # Return the gathered stats to caller.
    ,$StatsCollection
}