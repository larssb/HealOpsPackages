class StatsMember {
    # DECLARE PROPERTIES
    [String]
    $Metric

    $StatsData

    # DEFINE CONSTRUCTORS
    StatsMember([String] $Metric, [Int32] $StatsData) {
        [String]
        [ValidateNotNullOrEmpty()]
        $Metric

        [Int32]
        [ValidateNotNullOrEmpty()]
        $StatsData

        #
        $this.Metric = $Metric
        $this.StatsData = $StatsData
    }

    #
    StatsMember([String] $Metric, [HashTable] $StatsData) {
        [String]
        [ValidateNotNullOrEmpty()]
        $Metric

        [HashTable]
        [ValidateNotNullOrEmpty()]
        $StatsData

        #
        $this.Metric = $Metric
        $this.StatsData = $StatsData
    }
}