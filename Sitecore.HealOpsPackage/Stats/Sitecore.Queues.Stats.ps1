<#
.DESCRIPTION
    An implicit function that gathers statistics on the queues of a Sitecore installation.
.INPUTS
    <none>
.OUTPUTS
    A [System.Collections.Generic.List`1[StatsItem]] type collection, containing the [StatsItem]'s the function collected.
.NOTES
    Set to output [Void] in order to comply with the PowerShell language. Also if [Void] wasn't used, an error would be thrown when invoking the function.
    As the output type [System.Collections.Generic.List`1[StatsItem]] would not be known by PowerShell, when this function is invocated.
.EXAMPLE
    PS C:\> . ./Sitecore.Queues.Stats
    Executes Sitecore.Queues.Stats which will run through and try to gather stats data on the Sitecore queues.
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
    # General
    [int]$DataSrcIdx = 2
    [int]$DatabaseNameIdx = 3

    # Website
    $WebSiteName = "DanskeSpil.Website"

    # SQL infrastructure
    $CMServer = ""
    $QueueBehind_Query_SrvMatch = ""

    ##################
    # Database names #
    ##################
    # Core
    $CoreConnString = Get-WebConfiguration "IIS:\Sites\$WebSiteName\" -filter "connectionStrings/add[@name='core']"
    $CoreDB_DataSrc = ($CoreConnString.connectionString -split ";")[$DataSrcIdx] -replace ".+=",""
    $CoreDB_Name = ($CoreConnString.connectionString -split ";")[$DatabaseNameIdx] -replace ".+=",""

    # Web
    $WebConnString = Get-WebConfiguration "IIS:\Sites\$WebSiteName\" -filter "connectionStrings/add[@name='web']"
    $WebDB_DataSrc = ($WebConnString.connectionString -split ";")[$DataSrcIdx] -replace ".+=",""
    $WebDB_Name = ($WebConnString.connectionString -split ";")[$DatabaseNameIdx] -replace ".+=",""

    # Collection for holding stats data.
    $StatsCollection = Out-StatsCollectionObject

    <#
        - Define queries
    #>
    function Out-SiteCoreQuery() {
        # Define parameters
        [CmdletBinding(DefaultParameterSetName = "Default")]
        [OutputType([String])]
        param(
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [String]$DBName,
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [String]$TableName,
            [Parameter(Mandatory)]
            [ValidateSet('Count','QueueBehind')]
            [String]$QueryType
        )

        #############
        # Execution #
        #############
        Begin {}
        Process {
            switch ($QueryType) {
                'Count' {
                    [String]$Query = "SELECT count(*) FROM [$DBName].[dbo].[$TableName]"
                }
                'QueueBehind' {
                    [String]$Query = "SELECT p.[ID], p.[Key], p.[Value], (CONVERT(INT, CONVERT(NVARCHAR(100),pp.[Value])) - CONVERT(INT, CONVERT(NVARCHAR(100),p.[Value]))) as secsbehind
                    FROM [$DBName].[dbo].[$TableName] p
                    left outer join [$DBName].[dbo].[$TableName] pp ON pp.[key] = 'EQSTAMP_$CMServer'
                    where p.[key] like 'EQSTAMP_$QueueBehind_Query_SrvMatch%'"
                }
            }
        }
        End {
            # Return the generated query
            $Query
        }
    }
}
Process {
    <#
        - Event queue stats - OVERALL
    #>
    # Fetch count on the event queue table in the [CORE] db.
    $QueryToExecute_CoreDB = Out-SiteCoreQuery -DBName "$CoreDB_Name" -TableName "EventQueue" -QueryType "Count"
    $QueryResult_CoreDB = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $CoreDB_DataSrc -Query $QueryToExecute_CoreDB

    # Get a StatsItem object and populate its properties
    $StatsItem_CoreDB = Out-StatsItemObject
    $StatsItem_CoreDB.Metric = "sitecore.queue.event.coredb"
    $StatsItem_CoreDB.StatsData = @{
        "Value" = $QueryResult_CoreDB
    }

    # Add the result to the Stats collection.
    $StatsCollection.Add($StatsItem_CoreDB)

    # Fetch count on the event queue table in the [WEB] db.
    $QueryToExecute_WebDB = Out-SiteCoreQuery -DBName "$WebDB_Name" -TableName "EventQueue" -QueryType "Count"
    $QueryResult_WebDB = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $WebDB_DataSrc -Query $QueryToExecute_WebDB

    # Get a StatsItem object and populate its properties
    $StatsItem_WebDB = Out-StatsItemObject
    $StatsItem_WebDB.Metric = "sitecore.queue.event.webdb"
    $StatsItem_WebDB.StatsData = @{
        "Value" = $QueryResult_WebDB
    }

    # Add the result to the Stats collection.
    $StatsCollection.Add($StatsItem_WebDB)

    <#
        - Publish queue stats - OVERALL
    #>
    # Fetch count on the event queue table in the [CORE] db.
    $QueryToExecute_CoreDB = Out-SiteCoreQuery -DBName "$CoreDB_Name" -TableName "PublishQueue" -QueryType "Count"
    $QueryResult_CoreDB = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $CoreDB_DataSrc -Query $QueryToExecute_CoreDB

    # Get a StatsItem object and populate its properties
    $StatsItem_CoreDB = Out-StatsItemObject
    $StatsItem_CoreDB.Metric = "sitecore.queue.publishing.coredb"
    $StatsItem_CoreDB.StatsData = @{
        "Value" = $QueryResult_CoreDB
    }

    # Add the result to the Stats collection.
    $StatsCollection.Add($StatsItem_CoreDB)

    # Fetch count on the event queue table in the [WEB] db.
    $QueryToExecute_WebDB = Out-SiteCoreQuery -DBName "$WebDB_Name" -TableName "PublishQueue" -QueryType "Count"
    $QueryResult_WebDB = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $WebDB_DataSrc -Query $QueryToExecute_WebDB

    # Get a StatsItem object and populate its properties
    $StatsItem_WebDB = Out-StatsItemObject
    $StatsItem_WebDB.Metric = "sitecore.queue.publishing.webdb"
    $StatsItem_WebDB.StatsData = @{
        "Value" = $QueryResult_WebDB
    }

    # Add the result to the Stats collection.
    $StatsCollection.Add($StatsItem_WebDB)

    <#
        - Queue - Behind, per server, on CORE DB.
    #>
    $QueryToExecute_CoreDB = Out-SiteCoreQuery -DBName "$CoreDB_Name" -TableName "Properties" -QueryType "QueueBehind"
    $QueryResult_CoreDB = Invoke-DbaSqlQuery -SqlInstance $CoreDB_DataSrc -Query $QueryToExecute_CoreDB

    foreach ($Row in $QueryResult_CoreDB) {
        $StatsOwner = ($Row.Key -Split "_")[1]
        if (-not ($StatsOwner -match "CM")) {
            # Get a StatsItem object and populate its properties
            $StatsItem_CoreDB = Out-StatsItemObject -IncludeStatsOwnerProperty
            $StatsItem_CoreDB.Metric = "sitecore.queuebehind.coredb"
            $StatsItem_CoreDB.StatsData = @{
                "Value" = $Row.secsbehind
            }
            $StatsItem_CoreDB.StatsOwner = $StatsOwner

            # Add the result to the Stats collection.
            $StatsCollection.Add($StatsItem_CoreDB)
        } # End of conditional control, ensuring that we only get the metric on Sitecore CD/frontend servers.
    }
}
End {
    # Return the gathered stats to caller.
    ,$StatsCollection
}