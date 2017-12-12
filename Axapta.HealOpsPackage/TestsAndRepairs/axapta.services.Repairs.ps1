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
try {
    # Get all the Citrix services on the local computer. Uses the Displayname parameter as this is the best bet of getting Citrix services.
    $services = get-service -DisplayName "*Ax*"
} catch {
    $remediationResult = $false
}

if ($null -ne $services) {
    foreach ($service in $services) {
        if ($service.Status -ne "Running") {
            try {
                Start-Service $service
                
                $remediationResult = $true
            } catch {
                $remediationResult = $false
            }
        } else {
            $remediationResult = $true
        }
    }   
} else {
    $remediationResult = $false
}

# Return to caller
$remediationResult