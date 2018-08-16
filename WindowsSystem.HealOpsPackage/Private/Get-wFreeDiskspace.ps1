function Get-wFreeDiskspace() {
<#
.DESCRIPTION
    Returns the freespace of each drive on a Windows system.
.INPUTS
    <none>
.OUTPUTS
    [HashTable] - containing a curated object; DriveLetter;Freespace. Freespace is calculated to GB's for each drive on the Windows system.
.NOTES
    <none>
.EXAMPLE
    $freeSpace = Get-wFreeDiskspace
    > Returns the freespace of each drive on the Windows system.
#>

    # Define parameters
    [CmdletBinding()]
    [OutputType([HashTable])]
    param()

    #############
    # Execution #
    #############
    Begin {
        # Variables
        New-Variable -Name "FreeSpaceList" -Value (@{}) -Visibility Private -Option Constant -Scope Local -Force
    }
    Process {
        # Get the local drives
        $LocalDrives = get-wmiobject win32_volume | Where-Object { $_.DriveType -eq 3 -and $_.SystemVolume -eq $false }

        foreach ($Drive in $LocalDrives) {
            # Convert the space value to GB
            $FreeSpace = $Drive.FreeSpace/1GB
            $FreeSpace = [System.Math]::Ceiling($FreeSpace)

            # Derive the driveletter
            $Driveletter = $Drive.DriveLetter -replace ":",""
            $DriveletterDescription = ("Drive$Driveletter")

            # Add the freespace object to the list
            $FreeSpaceList.Add($DriveletterDescription,$FreeSpace)
        }
    }
    End{
        # Return
        ,$FreeSpaceList
    }
}