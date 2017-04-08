policydecision{
    # example if
    if(*size=="large"){* resourceName = "archive"}
    else{ ... }
    # example on
    *resourceName = storagepolicy(*size, *privacy, *availability)
    writeLine("stdout", "*resourceName")
}

    #example on
storagepolicy(*size, *privacy, *availability){
	on(*availability=="high"){"replResc"}
}

INPUT *size=<FILL IN>, *privacy=<FILL IN>, *availability=<FILL_IN> 
OUTPUT ruleExecOut

