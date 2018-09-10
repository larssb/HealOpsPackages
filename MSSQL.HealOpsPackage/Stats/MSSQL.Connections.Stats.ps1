<#
.DESCRIPTION
    Gathers connection stats on an MSSQL instance. Per database.
.INPUTS
    <none>
.OUTPUTS
    A [System.Collections.Generic.List`1[MetricItem]] type collection, containing the [MetricItem]'s the function collected.
.NOTES
    Set to output [Void] in order to comply with the PowerShell language. Also if [Void] wasn't used, an error would be thrown when invoking the function.
    As the output type [System.Collections.Generic.List`1[MetricItem]] would not be known by PowerShell, when this function is invocated.
.EXAMPLE
    PS C:\> . ./MSSQL.Connections.Stats
    Executes the MSSQL.Connections.Stats file.
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
    # Set of databases
    $Databases = @()

    # MSSQL instance
    $MSSQLInstance = ""

    # Initiate a collection to hold stats data.
    $MetricsCollection = Out-MetricsCollectionObject
}
Process {
    <#
        - YOUR_COMMENT
    #>
    # Gather number of connections per database on the specifieed MSSQL instance.
    foreach ($Database in $Databases) {
        [Array]$QueryResult = Invoke-DbaSqlQuery -SqlInstance $MSSQLInstance -Query "
            SELECT DB_NAME(dbid) as DBName, HostName, COUNT(dbid) as Connections
            FROM sys.sysprocesses with (nolock)
            WHERE dbid > 0
            and len(HostName) > 0
            and DB_NAME(dbid)='$Database'
            Group by DB_NAME(dbid),HostName
            Order by DBName
        "

        # Gather connection count per server.
        foreach ($Item in $QueryResult) {
            # Get a MetricItem object and populate its properties
            $MetricItem = Out-MetricItemObject -IncludeStatsOwnerProperty
            $MetricItem.Metric = "mssql.database.connections"
            $MetricItem.MetricData = @{
                "Database" = $Database
                "Value" = $Item.Connections
            }
            $MetricItem.StatsOwner = $Item.HostName.Trim()

            # Add the result to the Stats collection.
            $MetricsCollection.Add($MetricItem)
        }
    } # End of foreach on the databases in $Databases
}
End {
    # Return the gathered stats to caller.
    ,$MetricsCollection
}