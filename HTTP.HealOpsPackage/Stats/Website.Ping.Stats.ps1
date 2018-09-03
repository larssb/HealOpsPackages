<#
.DESCRIPTION
    Gets various stats on a Website.
.INPUTS
    <none>
.OUTPUTS
    A [System.Collections.Generic.List`1[StatsItem]] type collection, containing the [StatsItem]'s the function collected.
.NOTES
    Set to output [Void] in order to comply with the PowerShell language. Also if [Void] wasn't used, an error would be thrown when invoking the function.
    As the output type [System.Collections.Generic.List`1[StatsItem]] would not be known by PowerShell, when this function is invocated.
.EXAMPLE
    PS C:\> . ./Website.Ping.Stats.ps1
    Executes the file.
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