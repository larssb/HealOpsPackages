####
# PREP.
####
[String]$SubsonicSecret = Request-VaultSecret -Name httphealopspackage -SecretPath "subsonicApi"
Describe 'Subsonic.IbigServices' {
    # general variables
    $ibigServicesRootURI = "https://ibigservices.ddns.net";

    <#
        - Test the health of the Subsonic music service

        Runs on Tomcat
    #>
    It "The status of Subsonic should be ok" {
        # The subsonic health endpoint URI
        $subsonicHealthURI = "$ibigServicesRootURI/subsonic/rest/ping.view"

        # Prep. query parameters for the call to Subsonics health endpoint.
        $requestQuery = @{}
        $requestQuery.c = "subsonicHealth" # c for client application
        $requestQuery.f = "json" # f for format
        $requestQuery.s = Get-Random # s for salt

        # Get the password matching the user
        $password = $SubsonicSecret
        if ($IsMacOS -eq $true -or $IsLinux -eq $true) {
            # MacOS or Linux - use the MD5()
            $saltedPass = md5 -q -s $password$($requestQuery.s)
        }

        $requestQuery.t = $saltedPass # t for token.
        $requestQuery.u = "subsonicApi"; # u for user.
        $requestQuery.v = "1.15.0"; # v for version

        try {
            # Call the Subsonic health endpoint
            $requestResult = Invoke-WebRequest $subsonicHealthURI -Method Get -Body $requestQuery;
        } catch {
            $status = "not_ok"
        }

        $json = $requestResult.Content;
        $requestResult = ConvertFrom-Json $json;
        $status = $requestResult.'subsonic-response'.status;

        # Determine the result of this Pester test.
        $status | Should Be "ok";
    }
}