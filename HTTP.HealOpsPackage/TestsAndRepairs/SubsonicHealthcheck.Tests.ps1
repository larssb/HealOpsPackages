########
# PREP #
########
[String]$SubsonicSecret = Request-VaultSecret -Name "SECRET_NAME" -SecretPath "PATH_NAME"
[String]$SubsonicUser = "SUBSONIC_USERNAME"
[String]$SubsonicAPIVer = "1.15.0" # Change if the version does not match the Subsonic API version of your Subsonic installation.

########
# TEST #
########
Describe 'Subsonic.Healthcheck' {
    # general variables
    $SubsonicRootURI = "";

    <#
        - Test the health of the Subsonic music service

        Runs on Tomcat
    #>
    It "The status of Subsonic should be ok" {
        # The subsonic health endpoint URI
        $SubsonicHealthURI = "$SubsonicRootURI/subsonic/rest/ping.view"

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
        $requestQuery.u = $SubsonicUser # u for user.
        $requestQuery.v = $SubsonicAPIVer # v for version

        try {
            # Call the Subsonic health endpoint
            $RequestResult = Invoke-WebRequest $subsonicHealthURI -Method Get -Body $requestQuery -ErrorAction Stop
        } catch {
            $Status = "not_ok"
        }

        $json = $requestResult.Content
        $requestResult = ConvertFrom-Json $json
        $Status = $requestResult.'subsonic-response'.status

        # Determine the result of this Pester test.
        $Status | Should Be "ok"
    }
}