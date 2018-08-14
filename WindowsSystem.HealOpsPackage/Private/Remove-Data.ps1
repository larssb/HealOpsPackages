function Remove-Data() {
<#
.DESCRIPTION
    Removes data taking up disk usage on a node.
.INPUTS
    [String]Path on which to remove data.
    [int]DaysBack. A number pointing to how many days the search should go back before fetching data to remove.
    [String]Filter. Used to specify the filter to apply to the search for data to remove.
.OUTPUTS
    [String] stating whether data was removed or not.
.NOTES
    Important note 1. If you don't specify any value to the DaysBack parameter, data of any age will be deleted.
    Important note 2. If you don't specify any value to the Filter parameter, data of any type will be deleted.

    For both the above parameters. You can combine the two.
.EXAMPLE
    PS C:\> Remove-Data -DaysBack 30 -Path /usr/master/tmp
    Will try to remove data in the /usr/master/tmp folder (recursively), where data is older than 30 days.
.EXAMPLE
    PS C:\> Remove-Data -DaysBack 30 -Filter "*.log" -Path /usr/master/tmp
    Tries to remove data in the /usr/master/tmp folder (recursively), where data is older than 30 days and the data is of type .log.
.PARAMETER DaysBack
    The days to "go back in time", collect data in that data interval and remove the collected data.
.PARAMETER Filter
    With this parameter you can specify a -Filter that is compatible with the PowerShell *Item* related cmdlets.
.PARAMETER Path
    The path on which to remove data.
#>

    # Define parameters
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([String])]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [int]$DaysBack = 0,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$Filter,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String]$Path
    )

    #############
    # Execution #
    #############
    Begin {}
    Process {
        # Find all files that are older than the value in $DaysBack. Potentially with a defined -Filter.
        try {
            # Splat the parameters to be used on the Get-ChildItem cmdlet.
            $GetChildItemSplatting = @{
                Path = $Path
                Recurse = $true
            }
            if ($PSBoundParameters.ContainsKey('Filter')) {
                $UsingFilter = "A filter is used."
                $GetChildItemSplatting.Add("File",$Filter) | Out-Null
            } else {
                $UsingFilter = "A filter is not used."
            }
            $ItemsToDelete = Get-ChildItem @GetChildItemSplatting -ErrorAction Stop | Where-Object LastWriteTime -le ((get-date).AddDays($DaysBack)) -ErrorAction Stop
        } catch {
            throw "Failed to get items to delete. The error is > $_"
        }

        # Remove the "Identified" files.
        try {
            if ($ItemsToDelete.Count -gt 0){
                foreach ($Item in $ItemsToDelete){
                    $log4netLoggerDebug.Debug("Trying to delete $($Item.BaseName).")
                    Remove-Item -Path $($Item.FullName) -Force -ErrorAction Stop
                }
            } else {
                $log4netLoggerDebug.Debug("There was no files to remove in the folder $Path. $UsingFilter and the data query looked back $DaysBack days.")
                $RemoveDataResult = "NoDataRemoved"
            }
        } catch {
            throw "Failed to remove data in the folder $Path. The error is > $_"
        }
        $RemoveDataResult = "DataRemoved"
    } # End of process section.
    End {
        # Return
        $RemoveDataResult
    }
}