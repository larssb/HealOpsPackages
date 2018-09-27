#Requires -Modules WebAdminiStration
<#
.DESCRIPTION
    Counts the number of [ERROR] lines in the Sitecore log. This can be a good indicator to watch in regards to the health of a Sitecore instance.
.INPUTS
    <none>
.OUTPUTS
    A [System.Collections.Generic.List`1[MetricItem]] type collection, containing the [MetricItem]'s the function collected.
.NOTES
    Set to output [Void] in order to comply with the PowerShell language. Also if [Void] wasn't used, an error would be thrown when invoking the function.
    As the output type [System.Collections.Generic.List`1[MetricItem]] would not be known by PowerShell, when this function is invocated.

    Requires the WebAdminiStration module via a local 'Requires' clause as the WebAdministration module cannot be published with the Publish-Module cmdlet because pf some missing metadata.
.EXAMPLE
    PS C:\> ./Sitecore.log.Stats.ps1
    Execute this Stats file.
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
    # The name of the website running Sitecore.
    $WebSiteName = ""

    # Initiate a collection to hold stats data.
    $MetricsCollection = Out-MetricsCollectionObject
}
Process {
    <#
        - TEMP. Perf. improvements....implement the below
            > stop using get-content, select-string should be able to take a file directly
            > Use the .NET StreamReader > https://powershell.org/2013/10/21/why-get-content-aint-yer-friend/
                >> and a nice snippet here > https://foxdeploy.com/2016/03/23/coding-for-speed/
            > Test the ReadAllText() method. This coould be fast as well.
    #>

    # Get the physical path of the website
    $WebSitePath = (Get-Website -Name $WebSiteName).PhysicalPath
    $SitecoreLogPath = "$WebSitePath\App_Data\logs"

    # Get the newest Sitecore log &
    $Errors = Get-Item -Path $SitecoreLogPath/* -Include log* | Sort-Object -Property LastWriteTime | Select-Object -Last 1 | Get-Content | Select-String -CaseSensitive -Pattern "ERROR"

    # Get a MetricItem object and populate its properties
    $MetricItem = Out-MetricItemObject
    $MetricItem.Metric = "sitecore.log.errors"
    $MetricItem.MetricData = @{
        "Value" = $Errors.Count
    }

    # Add the result to the Stats collection.
    $MetricsCollection.Add($MetricItem)
}
End {
    # Return the gathered stats to caller.
    ,$MetricsCollection
}