Describe "citrix.services" {
    <#
        - Tests that all Citrix services is running
    #>
    It "All citrix services should be running" {
        # Get all the Citrix services on the local computer.
        $citrixServices = get-service -Name "Citrix*"

        foreach ($citrixService in $citrixServices) {
            if ($citrixService.Status -ne "Running") {
                $serviceOkay = 1
                $global:failedTestResult = 1
                break
            } else {
                $serviceOkay = 0
            }
        }

        # Determine the result of the test
        $global:passedTestResult = 0
        $serviceOkay | Should Be 0
    }
}