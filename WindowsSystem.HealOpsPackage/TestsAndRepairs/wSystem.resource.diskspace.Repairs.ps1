#########
# PREP. #
#########
# Define parameters
[CmdletBinding(DefaultParameterSetName="Default")]
[OutputType([Boolean])]
param(
    [Parameter(Mandatory, HelpMessage="Data from the result of testing the state of an IT Service/Entity.")]
    [ValidateNotNullOrEmpty()]
    $TestData
)

# Import the Get-wFreeDiskspace function
. $PSScriptRoot/../Private/Remove-Data.ps1
. $PSScriptRoot/../Private/Register-ServerRole.ps1

#############
# Execution #
#############
# Get the role of the server
$ServerRole = Register-ServerRole

# Clean-up space on the server related to the role of the server
switch ($ServerRole) {
    "IIS" {
        try {
            Import-Module -Name WebAdministration -Force -ErrorAction Stop
        } catch {
            throw "Failed to import the WebAdministration IIS PowerShell module. Cannot continue repairing diskspace issues on the server."
        }
        $DefaultISLogDir = (Get-WebConfigurationProperty "/system.applicationHost/sites/siteDefaults" -name logfile.directory).Value

        # Resolve potential Environment variables in the retrieved path.
        $DefaultISLogDir = [System.Environment]::ExpandEnvironmentVariables($DefaultISLogDir)
        Write-Verbose -Message "Determined the default IIS log dir. to be > $DefaultISLogDir"

        # Call Remove-Data free up diskspace
        try {
            Remove-Data -DaysBack 30 -Filter "*.log" -Path $DefaultISLogDir
        } catch {
            throw "$_"
        }

        # The process was completed with no exception. The repair process was completed successfully.
        $true
    }
    Default {
        throw "Unknown server role. Cannot continue."
    }
}