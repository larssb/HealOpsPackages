# Retrieve a collection for storing Metrics
$MetricsCollection = Out-MetricsCollectionObject

Describe "octopusdeploy.tentacle" {
    <#
        - Test that the Octopus Deploy tentacle agent is running
    #>
    It "The Octopus Deploy tentacle agent should be running" {
        # Define general variables
        $octopusDeployTentacleURI = "https://localhost:10933/";

        # Create .NET object for self-signed cert. handling.
        $definition = @"
        using System.Collections.Generic;
        using System.Net;
        using System.Net.Security;
        using System.Security.Cryptography.X509Certificates;

        public static class SSLValidator
        {
            private static Stack<System.Net.Security.RemoteCertificateValidationCallback > funcs = new Stack<System.Net.Security.RemoteCertificateValidationCallback>();

            private static bool OnValidateCertificate(object sender, X509Certificate certificate, X509Chain chain,
                                                        SslPolicyErrors sslPolicyErrors)
            {
                return true;
            }

            public static void OverrideValidation()
            {
                funcs.Push(ServicePointManager.ServerCertificateValidationCallback);
                ServicePointManager.ServerCertificateValidationCallback =
                    OnValidateCertificate;
            }

            public static void RestoreValidation()
            {
                if (funcs.Count > 0) {
                    ServicePointManager.ServerCertificateValidationCallback = funcs.Pop();
                }
            }
        }
"@

        # Request the Octopus Deploy Tentacle endpoint
        Add-Type $definition
        [SSLValidator]::OverrideValidation()
        try {
            $Request = Invoke-WebRequest -Uri $octopusDeployTentacleURI -Method Get -UseBasicParsing
        } catch {
            write-verbose -Message "The Octopus Deploy webrequest call failed. The error was > $_"
            $TestException = $_
        }
        [SSLValidator]::RestoreValidation()

        # Test if the request came through at all
        if($TestException) {
            # The request did not come through. Reasoning > the endpoint is not available therefore HTTP503
            $Value = 503
        } else {
            $Value = $Request.StatusCode
        }

        # Get a MetricItem
        $MetricItem = Out-MetricItemObject
        $MetricItem.Metric = "octopusdeploy.tentacle.status"
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