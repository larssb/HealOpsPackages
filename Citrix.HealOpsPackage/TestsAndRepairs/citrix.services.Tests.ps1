Describe "citrix.services" {
    <#
        - Tests that all Citrix services is running
    #>
    It "All citrix services should be running" {
        # Get all the Citrix services on the local computer. Uses the Displayname parameter as this is the best bet of getting Citrix services.
        $citrixServices = get-service -DisplayName "*Citrix*"

        if ($null -ne $citrixServices) {
            foreach ($citrixService in $citrixServices) {
                # The BNBOOTP svc. stops automatically. By design by Citrix.
                if ($citrixService.Status -ne "Running" -and $citrixService.Name -ne "BNBOOTP") {
                    $serviceOkay = 1
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
        $global:assertionResult = 0
        $serviceOkay | Should Be 0
    }
}