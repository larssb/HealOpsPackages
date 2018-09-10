# Define parameters
[CmdletBinding()]
[OutputType([Boolean])]
param(
    [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="Data from the result of testing the state of an IT Service/Entity.")]
    [ValidateNotNullOrEmpty()]
    $TestData
)

#############
# Execution #
#############
Write-Verbose -Message "Trying to remediate the Octopus Deploy tentacle as it was in a failed state"

# Service unavailable. Let's try a service restart
$svc = Get-Service -Name "OctopusDeploy Tentacle"
if($null -ne $svc) {
    try {
        Start-Service  $svc
        $RemediationResult = $true
    } catch {
        Write-Output "Failed to start the Octopus Deploy service. Failed with: $_"
        $RemediationResult = $false
    }
} else {
    $RemediationResult = $false
}

# Return to caller
$RemediationResult