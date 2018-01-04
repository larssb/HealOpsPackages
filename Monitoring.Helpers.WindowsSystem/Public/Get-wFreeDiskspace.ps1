function Get-wFreeDiskspace() {
<#
.DESCRIPTION
    Long description
.INPUTS
    Inputs (if any)
.OUTPUTS
    Outputs (if any)
.NOTES
    General notes
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.PARAMETER NAME_OF_THE_PARAMETER_WITHOUT_THE_QUOTES
    Parameter_HelpMessage_text
    Add_a_PARAMETER_per_parameter
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List])]
    param(
        [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="MESSAGE")]
        [ValidateNotNullOrEmpty()]
        $NAMEOFPARAMETER
    )

    #############
    # Execution #
    #############
    Begin {
        # Variables
        New-Variable -Name "FreeSpaceList" -Value (New-Object System.Collections.Generic.List[UInt64]) -Visibility Private -Option Constant -Scope Script
    }
    Process {
        # Get the local drives
        $localDrives = get-wmiobject win32_volume | Where-Object { $_.DriveType -eq 3 -and $_.SystemVolume -eq $false }

        foreach ($drive in $localDrives) {
            # Calculate free space available
            $freeSpaceOkay = $drive.FreeSpace/1GB -gt 10

            if($freeSpaceOkay -eq $false) {
                # We need to alert / remediate
                $result = 0

                # Break as there is no need to continue iterating
                break
            } else {
                $result = 1
            }
        }
    }
    End{}
}