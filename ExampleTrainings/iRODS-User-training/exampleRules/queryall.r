queryall{
	foreach(*row in SELECT COLL_NAME, <FILL IN> where <FILL IN> like '*var'){
		*coll = *row.COLL_NAME;
       *value = *row.<FILLIN>;
       writeLine("stdout", "<Some output>");
   	}
   	foreach(*row in SELECT COLL_NAME, <FILL IN>, <FILL_IN> where <FILL IN> like '*var'){
		*coll = *row.COLL_NAME;
		*data = *row.<FILL IN>;
       *value = *row.<FILL IN>;
       writeLine("stdout", "<Some output>");
    }
}

input *var='Easter'
output ruleExecOut
