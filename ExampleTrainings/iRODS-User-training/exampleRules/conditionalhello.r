conditionalhello{
    if(*name!="Your Name"){
        writeLine("stdout", "Hello *name!");
        }
    else { writeLine("stdout", "Hello world!"); }
}
INPUT *name="Your Name"
OUTPUT ruleExecOut, *name
