<#
.DESCRIPTION
    Gets various stats on a Website.
.INPUTS
    <none>
.OUTPUTS
    [VOID] to follow the PowerShell convention of specifying [Void] if the return type is not known by the type system.
.NOTES
    <none>
.EXAMPLE
    PS C:\> . ./Website.Ping.Stats.ps1
    Executes the file.
#>

# Define parameters
[CmdletBinding(DefaultParameterSetName = "Default")]
[OutputType([Void])]
Param(
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $NAMEOFPARAMETER
)

#############
# Execution #
#############
Begin {
    <#
        - Declare variables, that will be re-used throughout the script.
    #>
    [String]$URI = "https://bengtssondd.it"

    # Initiate a collection to hold stats data.
    $StatsCollection = Out-StatsCollectionObject
}
Process {
    <#
        - YOUR_COMMENT
    #>
    # Request the blog
    $Time = Measure-Command -Expression {
        Invoke-WebRequest -Method Get -Uri $URI
    }

    # Get a StatsItem object and populate its properties
    $StatsItem = Out-StatsItemObject
    $StatsItem.Metric = "bdd.blog.responsetime"
    $StatsItem.StatsData = @{
        "ResponseTime" = $Time.Milliseconds
    }

    # Add the result to the Stats collection.
    $StatsCollection.Add($StatsItem)
}
End {
    # Return the gathered stats to caller.
    $StatsCollection
}