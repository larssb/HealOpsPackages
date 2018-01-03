# Define parameters
[CmdletBinding()]
[OutputType([Boolean])]
param(
    [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="Data from the result of testing the state of an IT Service/Entity.")]
    [ValidateNotNullOrEmpty()]
    $TestData
)

####################
# Helper functions #
####################
function Start-MyService () {
    [CmdletBinding()]
    [OutputType([Boolean])]
    param(
        [Parameter(Mandatory=$true, HelpMessage="A Windows service object. Representing the service to be started.")]
        [ServiceController]$service
    )

    #############
    # Execution #
    #############
    try {
        # It is not in a pending state. Must be stopped. Start it.
        Start-Service $service -ErrorAction Stop
        $remediationResult = $true
    } catch {
        $remediationResult = $false
    }

    # Return
    $remediationResult
}

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
        # Check if the service is pending (Stop or Start pending)
        $pendingService = Get-WmiObject -Class win32_service -Filter "Name = '$($citrixService.Name)' and state like '%Pending'"

        if ($null -ne $pendingService) {
            try {
                # Stop the service from being in a pending state
                Stop-Process -Id $pendingService.processid -Force -ErrorAction Stop
                $remediationResult = $true
            } catch {
                $remediationResult = $false
            }

            # Now start the service again after having handled the pending state of the service
            $remediationResult = Start-MyService -service $citrixService
        } elseif ($citrixService.Status -ne "Running") {
            try {
                # It is not in a pending state. Must be stopped. Start it.
                $remediationResult = Start-MyService -service $citrixService
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