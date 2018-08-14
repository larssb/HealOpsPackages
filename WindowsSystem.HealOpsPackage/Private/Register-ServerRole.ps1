function Register-ServerRole() {
<#
.DESCRIPTION
    Registers the role of the server on which the functio is invocated.
.INPUTS
    None.
.OUTPUTS
    [String] representing the server role of the server.
.NOTES
    None
.EXAMPLE
    PS C:\> Register-ServerRole
    Executes Register-ServerRole in order to determine the role the server is running.
#>

    # Define parameters
    [CmdletBinding(DefaultParameterSetName = "Default")]
    [OutputType([String])]
    param()

    #############
    # Execution #
    #############
    Begin {
        # Import the ServerManager module. As that will be used to determine the role of the server.
        try {
            Import-Module -Name ServerManager -Force -ErrorAction Stop
        } catch {
            throw "Failed to import the ServerManager module. Failed with > $_. Cannot repair failed disk resource state."
        }
    }
    Process {
        # Control if the server has the IIS role.
        $InstalledFeatures = Get-WindowsFeature | Where-Object { $_.InstallState -eq "Installed" }
        if ($InstalledFeatures.Name -contains "Web-Server") {
            $ServerRole = "IIS"
        }
    }
    End {
        $ServerRole
    }
}