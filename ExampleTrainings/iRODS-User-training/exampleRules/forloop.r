forloop{
    for(*A = *B; *A < 1020; *A = *A+2){
        writeLine("stdout", *A)
    }
}

input *B=500*2+1
output ruleExecOut, *A, *B

