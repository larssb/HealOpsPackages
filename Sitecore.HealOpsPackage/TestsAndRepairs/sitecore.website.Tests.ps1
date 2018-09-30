# Retrieve a collection for storing Metrics
$MetricsCollection = Out-MetricsCollectionObject

Describe "sitecore.website" {
    <#
        - Test that the Sitecore website instance is up
    #>
    It "Sitecore should return HTTP200" {
        <#
            - Set webrequest variables

            N.B. the below endpoint tests the following:
                1. that the mongodb backend is up
                2. that the MSSQL backend is up
                3. Implicitly that the IIS website is up and running.
                    3a. Thereby implicitly that the app. pool for the website is running.

            N.B. IT IS NOT A STD. ENDPOINT. SO IT IS NOT AVAILBLE ON A VANILLA SITECORE INSTALLATION!
        #>
        $URI = "http://localhost:8080/Components/Common/Framework/Healthcheck/Presentation/SystemDiagnostics.aspx"

        # request the endpoint
        try {
            $Request = Invoke-WebRequest -Uri $URI -Method Get -UseBasicParsing
        } catch {
            Write-Verbose -Message "The Sitecore webrequest call failed. The error was > $_"
            $TestException = $_
        }

        # Test if the request came through at all
        if($TestException) {
            # The request did not come through. Reasoning > the endpoint is not available therefore HTTP503
            $Value = 503
        } else {
            $Value = $Request.StatusCode
        }

        # Get a MetricItem
        $MetricItem = Out-MetricItemObject
        $MetricItem.Metric = "sitecore.website.status"
        $MetricItem.MetricData = @{
            "Value" = $Value
        }

        # Add the metric to the MetricsCollection
        $MetricsCollection.Add($MetricItem)

        # Set global report variables
        $global:passedTestResult = $MetricsCollection
        $global:failedTestResult = $MetricsCollection

        <#
            - ASSERT
        #>
        $Value | Should Not Be 503
        $Value | Should Be 200
    }
}