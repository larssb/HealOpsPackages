Describe "sitecore.website" {
    <#
        - Test that the Sitecore website instance is ready
    #>
    It "Sitecore should return HTTP200" {
        <#
            - Set webrequest variables

            N.b. the below endpoint tests the following:
                1. that the mongodb backend is up
                2. that the MSSQL backend is up
                3. Implicitly that the IIS website is up and running.
                    3a. Thereby implicitly that the app. pool for the website is running.
        #>
        $uri = "http://localhost:8080/Components/Common/Framework/Healthcheck/Presentation/SystemDiagnostics.aspx"

        # request the endpoint
        try {
            $request = Invoke-WebRequest -Uri $uri -Method Get -UseBasicParsing
        } catch {
            write-verbose -Message "The Sitecore webrequest call failed. The error was > $_"
            
            $testException = $_
        }

        # Test if the request came through at all
        if($testException) {
            # The request did not come through. Reasoning > the endpoint is not available therefore HTTP503
            $testException = 503
        }
        $testException | Should Not Be 503

        # Determine the result of the test
        $global:assertionResult = $request.StatusCode        
        $request.StatusCode | Should be 200
    }
}