#using namespace System.Collections.Generic

class StatsCollection {
    # DECLARE PROPERTIES
    hidden $Collection = [System.Collections.Generic.List[Hashtable]]::new()

    # DECLARE CONSTRUCTORS
<#     StatsCollection([Hashtable] $StatsCollection) {
        $this.Collection
    } #>
}