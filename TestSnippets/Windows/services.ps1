# Get services
$services = get-service -DisplayName "* NAME_TO_LOOK_FOR *"
        
if ($null -ne $services) {
    foreach ($service in $services) {
        # The BNBOOTP svc. stops automatically. By design by Citrix.
        if ($service.Status -ne "Running") {
            $serviceOkay = 1
            $global:failedTestResult = 1                    
            break
        } else {
            $serviceOkay = 0
        }
    }
} else {
    # Either Citrix is not installed on this node or trying to get the Citrix services failed.
    $serviceOkay = 1
}
                    
# Determine the result of the test
$global:passedTestResult = 0
$serviceOkay | Should Be 0