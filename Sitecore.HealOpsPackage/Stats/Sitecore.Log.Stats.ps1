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
    # Get the physical path of the website
    $WebSitePath = (Get-Website -Name $WebSiteName).PhysicalPath

    # Get the newest Sitecore log
    $SitecoreLogPath = "$WebSitePath\App_Data\logs"
    $SitecoreLog = Get-Item -Path $SitecoreLogPath/* -Include log* | Sort-Object -Property LastWriteTime | Select-Object -Last 1

    # Setup a streamreader to process the Sitecore log
    [System.Collections.ArrayList]$Results = New-Object System.Collections.ArrayList
    try {
        $FileOpen = [System.IO.File]::Open($($SitecoreLog.FullName), "Open", "Read", "ReadWrite")
        $File = New-Object System.IO.StreamReader -ArgumentList $FileOpen
    } catch {
        $log4netLogger.error("Failed accessing the Sitecore logfile at $($SitecoreLog.FullName). Failed with > $_")
    }

    # Process the Sitecore log
    :loop while ($true)
    {
        # Read this line
        $Line = $File.ReadLine()
        if ($null -eq $Line) {
            # If the line was $null, we're at the end of the file, let's break
            $File.close()
            break loop
        }

        # Find all ERROR log lines
        if($Line.Contains('ERROR')) {
            $Results.Add($Line) | Out-Null
        }
    }

    # Get a MetricItem object and populate its properties
    $MetricItem = Out-MetricItemObject
    $MetricItem.Metric = "sitecore.log.errors"
    $MetricItem.MetricData = @{
        "Value" = $Results.Count
    }

    # Add the result to the Stats collection.
    $MetricsCollection.Add($MetricItem)
}
End {
    # Return the gathered stats to caller.
    ,$MetricsCollection
}