<#
.DESCRIPTION
    Counts the number of locks at a MSSQL instance level.
.INPUTS
    <none>
.OUTPUTS
    A [System.Collections.Generic.List`1[MetricItem]] type collection, containing the [MetricItem]'s the function collected.
.NOTES
    Set to output [Void] in order to comply with the PowerShell language. Also if [Void] wasn't used, an error would be thrown when invoking the function.
    As the output type [System.Collections.Generic.List`1[MetricItem]] would not be known by PowerShell, when this function is invocated.
.EXAMPLE
    PS C:\> . ./MSSQL.Locks.Stats.ps1
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
    <#
        - Declare variables, that will be re-used throughout the script.
    #>
    $MSSQLInstance = ""

    # Initiate a collection to hold stats data.
    $MetricsCollection = Out-MetricsCollectionObject
}
Process {
    # Gather locks info on the instance level.
    [Array]$QueryResult = Invoke-DbaSqlQuery -Database "DevOpsTools" -SqlInstance $MSSQLInstance -Query "exec sp_WhoIsActive"

    [Int32]$LockCount = 0
    foreach ($item in $QueryResult) {
        if ($item.blocking_session_id.GetType().Name -ne "DBNull") {
            $LockCount++
        }
    }

    # Get a MetricItem object and populate its properties
    $MetricItem = Out-MetricItemObject
    $MetricItem.Metric = "mssql.instance.locks"
    $MetricItem.MetricData = @{
        "Value" = $LockCount
    }

    # Add the result to the Stats collection.
    $MetricsCollection.Add($MetricItem)
}
End {
    # Return the gathered stats to caller.
    ,$MetricsCollection
}