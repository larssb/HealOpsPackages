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
        [System.ServiceProcess.ServiceController]$service
    )

    #############
    # Execution #
    #############
    try {
        Write-Verbose -Message "Trying to start the service named $($service.Name)."

        # It is not in a pending state. Must be stopped. Start it.
        Start-Service -Name $($service.Name) -ErrorAction Stop
        $remediationResult = $true
    } catch {
        $remediationResult = $false
        Write-Verbose -Message "Start-Service failed with > $_"
    }

    # Return
    $remediationResult
}

#############
# Execution #
#############
try {
    # Get all the Citrix services on the local computer. Uses the Displayname parameter as this is the best bet of getting Citrix services.
    $citrixServices = get-service -DisplayName "*Citrix*" | Where-Object { $_.Name -ne "BNBOOTP" }
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
                Write-Verbose -Message "Stop-Process failed with > $_"
            }

            # Now start the service again after having handled the pending state of the service
            $remediationResult = Start-MyService -service $citrixService
        } elseif ($citrixService.Status -ne "Running") {
            try {
                $serviceObjectType = $citrixService.GetType()
                Write-Verbose -Message "type info > $serviceObjectType"
                # It is not in a pending state. Must be stopped. Start it.
                $remediationResult = Start-MyService -service $citrixService
            } catch {
                $remediationResult = $false
                Write-Verbose -Message "Start-MyService failed with > $_"
                break
            }
        } else {
            $remediationResult = $true
            Write-Verbose -Message "No need to start the service. It is already started."
        }
    }
} else {
    $remediationResult = $false
}

# Return to caller
$remediationResult