# Define parameters
[CmdletBinding()]
[OutputType([Boolean])]
param(
    [Parameter(Mandatory=$true, ParameterSetName="Default", HelpMessage="Data from the result of testing the state of an IT Service/Entity.")]
    [ValidateNotNullOrEmpty()]
    $TestData
)

#############
# Execution #
#############

<#
    PSEUDO

    - Do disk clean-ups based on the role of the server. As we from that can infer where we are likely to be able to "pickup" harddisk space that we can safely
    clean-up
#>

$true