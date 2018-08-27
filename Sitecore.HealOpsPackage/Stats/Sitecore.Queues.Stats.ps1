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

    # Collection for holdting stats data.
    $Stats = @{}

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
    $QueryToExecute_Core = Out-SiteCoreQuery -DBName "$CoreDB_Name" -TableName "EventQueue" -QueryType "Count"
    $QueryResult_Core = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $CoreDB_DataSrc -Query $QueryToExecute_Core

    # Fetch count on the event queue table in the [WEB] db.
    $QueryToExecute_Web = Out-SiteCoreQuery -DBName "$WebDB_Name" -TableName "EventQueue" -QueryType "Count"
    $QueryResult_Web = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $WebDB_DataSrc -Query $QueryToExecute_Web

    # Add the numbers together for summarized count.
    $EventQueue_Total = $QueryResult_Core + $QueryResult_Web

    # Add the result to the Stats hashtable.
    $Stats.Add("EventQueueCount",$EventQueue_Total) | Out-Null

    <#
        - Publish queue stats - OVERALL
    #>
    # Fetch count on the event queue table in the [CORE] db.
    $QueryToExecute_Core = Out-SiteCoreQuery -DBName "$CoreDB_Name" -TableName "PublishQueue" -QueryType "Count"
    $QueryResult_Core = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $CoreDB_DataSrc -Query $QueryToExecute_Core

    # Fetch count on the event queue table in the [WEB] db.
    $QueryToExecute_Web = Out-SiteCoreQuery -DBName "$WebDB_Name" -TableName "PublishQueue" -QueryType "Count"
    $QueryResult_Web = Invoke-DbaSqlQuery -As SingleValue -SqlInstance $WebDB_DataSrc -Query $QueryToExecute_Web

    # Add the numbers together for summarized count.
    $PublishQueue_Total = $QueryResult_Core + $QueryResult_Web

    # Add the result to the Stats hashtable.
    $Stats.Add("PublishQueueCount",$PublishQueue_Total) | Out-Null

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
    $Stats
}