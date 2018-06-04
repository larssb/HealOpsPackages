####
# PREP.
####
[String]$Name = "httphealopspackage"
# Get the AppRole RoleID of the user with access to read the required secrets.
try {
    [String]$VaultRoleID = Read-AppRoleRoleID -EnvironmentVariableName $Name -ErrorAction Stop
} catch {
    Write-Error -Exception "Failed to get the RoleID. Failed with > $_"
}

#
try {
    $WrappedSecretID = Get-AppRoleSecretID -RoleName $Name -Wrapped -ErrorAction Stop
} catch {

}

# Unwrap the SecretID
try {
    Get-AppRoleUnwrappedSecretID -RoleName $Name
} catch {

}

# Login to Vault
try {
    Login-AppRole -RoleID $VaultRoleID -SecretID
} catch {

}

# Get the required secrets
try {

} catch {

}


Describe "name.in.this.format" {
    <#
        - "Describe what the test does"
    #>
    It "NAME_THE_TEST" {
        #
        'TEST_CODE_HERE'
        $global:failedTestResult =

        # Determine the result of the test
        $global:passedTestResult =
        $ | Should .....
    }
}