. ./StatsCollection.Class.ps1
. ./StatsItem.Class.ps1

$StatsCollection = [StatsCollection]::new()
$StatsItem = [StatsItem]::new("sitecore.queues.eventqueue", @{
    "Name" = "Jens Otto"
})

write-output "$($StatsItem | Out-String)"
$StatsCollection.Add([System.Guid]::NewGuid(),$StatsItem)

foreach ($item in $StatsCollection) {
    Write-Output "The item > $($item | Out-String)"
}

#
# The above works.
#

<#
    STATUS

    - Collection not working as I want it to. Consider just providing a method for the *.Stats.ps1 script developer to use.
        --> Out-StatsCollection > no parms.
    - Consider if it would be better to have the class in the HealOps module
        --> consider the implications of this.
        --> seriously consider how the *.Stats.ps1 developer will then have to work.
        --> Likely a good thing to move intelligence away from the HealOpsPackages. They should be as simple as possible to develop. They are the entities that 'x' dev will
        work with.
#>