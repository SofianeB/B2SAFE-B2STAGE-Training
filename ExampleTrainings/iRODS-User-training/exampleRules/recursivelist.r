recursivelist{
    *home="/$rodsZoneClient/home/$userNameClient"
    writeLine("stdout","Listing *home");
    foreach(*row in SELECT COLL_NAME, DATA_NAME WHERE COLL_NAME like '*home%'){
        *coll = *row.COLL_NAME;
        *data = *row.DATA_NAME;
        writeLine("stdout", "*coll/*data");
    }
}

input null
output ruleExecOut
