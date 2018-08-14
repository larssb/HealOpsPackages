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
        $localDrives = get-wmiobject win32_volume | Where-Object { $_.DriveType -eq 3 -and $_.SystemVolume -eq $false }

        foreach ($drive in $localDrives) {
            # Convert the space value to GB
            $freeSpace = $drive.FreeSpace/1GB
            $freeSpace = [System.Math]::Ceiling($freeSpace)

            # Derive the driveletter
            $driveletter = $localDrives.DriveLetter -replace ":",""
            $driveletterDescription = ("Drive$driveletter")

            # Add the freespace object to the list
            $FreeSpaceList.Add($driveletterDescription,$freeSpace)
        }
    }
    End{
        # Return
        ,$FreeSpaceList
    }
}