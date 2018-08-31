<#
.DESCRIPTION
    An implicit function that gathers statistics on the queues of a Sitecore installation.
.INPUTS
    Inputs (if any)
.OUTPUTS
    [Hashtable]Stats. This collection contains the gathered Sitecore queue stas.
.NOTES
    <none>
.EXAMPLE
    PS C:\> . ./Sitecore.Queues.Stats
    Executes Sitecore.Queues.Stats which will run through and try to gather stats data on the Sitecore queues.
#>

# Define parameters
[CmdletBinding(DefaultParameterSetName = "Default")]
[OutputType([Hashtable])]
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

    # Metric to use when reporting to the time-series database.
    $MetricEventQueueCount = "sitecore.queue.event"
    $MetricPublishingQueueCount = "sitecore.queue.publishing"

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
            [ValidateSet('Count','')]
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
                '' {

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
    $StatsItem_CoreDB.StatsData = $QueryResult_CoreDB

    # Add the result to the Stats collection.
    $StatsCollection.Add($StatsItem_CoreDB)

    # Fetch count on the event queue table in the [WEB] db.
    $QueryToExecute_WebDB = Out-SiteCoreQuery -DBName "$WebDB_Name" -TableName "EventQueue" -QueryType "Count"
    $QueryResult_WebDB = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $WebDB_DataSrc -Query $QueryToExecute_WebDB

    # Get a StatsItem object and populate its properties
    $StatsItem_WebDB = Out-StatsItemObject
    $StatsItem_WebDB.Metric = "sitecore.queue.event.webdb"
    $StatsItem_WebDB.StatsData = $QueryResult_CoreDB

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
    $StatsItem_CoreDB.StatsData = $QueryResult_CoreDB

    # Add the result to the Stats collection.
    $StatsCollection.Add($StatsItem_CoreDB)

    # Fetch count on the event queue table in the [WEB] db.
    $QueryToExecute_WebDB = Out-SiteCoreQuery -DBName "$WebDB_Name" -TableName "PublishQueue" -QueryType "Count"
    $QueryResult_WebDB = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $WebDB_DataSrc -Query $QueryToExecute_WebDB

    # Get a StatsItem object and populate its properties
    $StatsItem_WebDB = Out-StatsItemObject
    $StatsItem_WebDB.Metric = "sitecore.queue.publishing.webdb"
    $StatsItem_WebDB.StatsData = $QueryResult_CoreDB

    # Add the result to the Stats collection.
    $StatsCollection.Add($StatsItem_WebDB)

    <#
        - Event queue stats - Per server
    #>

    <#
        - Publish queue stats - Per server
    #>

    <#
        - Event queue stats - Behind, per server
    #>

    <#
        - Publish queue stats - Behind, per server
    #>
<#     SELECT p.[ID]
    ,p.[Key]
    ,p.[Value]
     ,(CONVERT(INT, CONVERT(NVARCHAR(100),pp.[Value])) - CONVERT(INT, CONVERT(NVARCHAR(100),p.[Value]))) as span
FROM [DanskeSpil_Website_Core].[dbo].[Properties] p
left outer join [DanskeSpil_Website_Core].[dbo].[Properties] pp ON pp.[key] = 'EQSTAMP_PWSCM001DLI'
where p.[key] like 'EQSTAMP_PWS%' #>

    <#

    #>
}
End {
    # Return the gathered stats to caller.
    $StatsCollection
}