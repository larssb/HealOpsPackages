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
    # Set of databases
    $Databases = @(
        "Town36_DanskeSpil_Website_Core"
        "Town36_DanskeSpil_Website_Data"
        "Town36_DanskeSpil_Website_Master"
        "Town36_DanskeSpil_Website_Sessions"
        "Town36_DanskeSpil_Website_SharedSessions"
        "Town36_DanskeSpil_Website_Web"
        "Town36_DanskeSpil_Website_Analytics"
        "Town36_DanskeSpil_Website_Analytics_Secondary"
    )

    # MSSQL instance
    $MSSQLInstance = "10.93.1.15"

    # Initiate a collection to hold stats data.
    $StatsCollection = Out-StatsCollectionObject
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
            # Get a StatsItem object and populate its properties
            $StatsItem = Out-StatsItemObject -IncludeStatsOwnerProperty
            $StatsItem.Metric = "mssql.database.connections"
            $StatsItem.StatsData = @{
                "Database" = $Database
                "Value" = $Item.Connections
            }
            $StatsItem.StatsOwner = $Item.HostName.Trim()

            # Add the result to the Stats collection.
            $StatsCollection.Add($StatsItem)
        }
    } # End of foreach on the databases in $Databases
}
End {
    # Return the gathered stats to caller.
    ,$StatsCollection
}