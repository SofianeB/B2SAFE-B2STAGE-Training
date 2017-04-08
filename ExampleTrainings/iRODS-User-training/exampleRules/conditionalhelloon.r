hellorule{
    *result = hello(*name);
    writeLine("stdout", "*result");
}

hello(*name){
    on(*name=="Your Name")
        { "Hello world!"; }
}

hello(*name){
    "Hello *name!";
}

INPUT *name="Your Name"
OUTPUT ruleExecOut, *name
