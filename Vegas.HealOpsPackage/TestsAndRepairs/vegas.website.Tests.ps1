Describe "vegas.sitecore.website" {
    <#
        - Test that the Sitecore website instance is ready
    #>
    It "Vegas.dk should return HTTP200" {
        <#
            - Set webrequest variables
                1: That the IIS website is up and running.
                    1a: Thereby implicitly that the app. pool for the website is running.
        #>
        $uri = "http://localhost:8080"

        # request the endpoint
        try {
            $request = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing
        } catch {
            write-verbose -Message "The Vegas.dk webrequest call failed. The error was > $_"

            $testException = $_
        }

        # Test if the request came through at all
        if($testException) {
            # The request did not come through. Reasoning > the endpoint is not available therefore HTTP503
            $testException = 503
        }
        $testException | Should Not Be 503

        # Declare the global failure variable.
        $global:failedTestResult = $testException

        # Determine the result of the test
        $global:passedTestResult = $request.StatusCode
        $request.StatusCode | Should be 200
    }
}