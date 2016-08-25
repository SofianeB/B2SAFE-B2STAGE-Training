eudatRepl{
    # Data set replication
    # registered data (with PID registration) (3rd argument - 1st bool("true"))
    # recursive (4th argument 2nd bool("true"))
    EUDATReplication(*source, *destination, bool("true"), bool("true"), *response)
}
INPUT *source='/aliceZone/home/alice/Collection', *destination='/bobZone/home/alice#aliceZone/Collection'
OUTPUT ruleExecOut
