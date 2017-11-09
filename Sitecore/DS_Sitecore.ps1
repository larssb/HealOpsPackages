#Requires -Module HealOps
<#
    - Script for invoking HealOps on a Sitecore instance runing at Danske Spil
#>
$HealOpsPackageConfigPath = "$PSScriptRoot/Config/Sitecore.HealopsPackage.json"

# IIS Performance test
Invoke-HealOps -TestFilePath $PSScriptRoot\TestsAndRepairs\iis.performance.Tests.ps1 -HealOpsPackageConfigPath $HealOpsPackageConfigPath

# IIS Logs test
Invoke-HealOps -TestFilePath $PSScriptRoot\TestsAndRepairs\iis.resource.logs.Tests.ps1 -HealOpsPackageConfigPath $HealOpsPackageConfigPath

# Test the Octopus Deploy tentacle (Agent)
Invoke-HealOps -TestFilePath $PSScriptRoot\TestsAndRepairs\octopusdeploy.tentacle.Tests.ps1 -HealOpsPackageConfigPath $HealOpsPackageConfigPath

# Test that the sitecore website is up
Invoke-HealOps -TestFilePath $PSScriptRoot\TestsAndRepairs\sitecore.website.Tests.ps1 -HealOpsPackageConfigPath $HealOpsPackageConfigPath

# Test for enough diskspace
Invoke-HealOps -TestFilePath $PSScriptRoot\TestsAndRepairs\system.resource.diskspace.Tests.ps1 -HealOpsPackageConfigPath $HealOpsPackageConfigPath