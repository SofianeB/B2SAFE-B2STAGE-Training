policydecision{
	*resourceName = storagepolicy(*size, *privacy, *availability);
	writeLine("stdout", "*resourceName");
}

storagepolicy(*size, *privacy, *availability){
	on(*privacy=="high"){ "storage3"; }
}

storagepolicy(*size, *privacy, *availability){
	on(*availability=="high"){ "replResc"; }
}

storagepolicy(*size, *privacy, *availability){
	on(*size=="large"){ "archive"; }
}

storagepolicy(*size, *privacy, *availability){
	"demoResc";
}

INPUT *size="large", *privacy="low", *availability="high" 
OUTPUT ruleExecOut
