Describe "axapta.services" {
    <#
        - Tests that required Axapta services are started on the node.
    #>
    It "All Axapta services should be started" {
        # Get all Axapta services on the node
        $services = get-service -DisplayName "*Ax*"
        
        if ($null -ne $services) {
            foreach ($service in $services) {
                if ($services.Status -ne "Running") {
                    $serviceOkay = 1
                    $global:failedTestResult = 1                    
                    break
                } else {
                    $serviceOkay = 0
                }
            }
        } else {
            # Either Axapta is not installed on this node or trying to get the Axapta services failed.
            $serviceOkay = 1
        }
                    
        # Determine the result of the test
        $global:passedTestResult = 0
        $serviceOkay | Should Be 0
    }
}