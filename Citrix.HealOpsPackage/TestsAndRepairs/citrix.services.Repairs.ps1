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
    $citrixServices = get-service -DisplayName "*Citrix*"
} catch {
    $remediationResult = $false
}

if ($null -ne $citrixServices) {
    foreach ($citrixService in $citrixServices) {
        if ($citrixService.Status -ne "Running") {
            try {
                Start-Service $citrixService -ErrorAction Stop

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