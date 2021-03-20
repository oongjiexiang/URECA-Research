#!/bin/bash

awk -v selectors=$1 'BEGIN {
    FS="|"; getline; 
    n = split(selectors, select, "|");
    for(i = 1; i <= n; i++){
        echo select[i]
        for(j = 1; j <= NF; j++){
            if(select[i] == $j){    col[select[i]] = j;     }
        }
    }
}
{
    # able to refer to the variables by name (the name should contain no spaces)
    # if the name is not the header, the whole record will be printed
    print $col["Date"]
}


' data_test.csv >data_out.csv

# split command [https://stackoverflow.com/questions/23763046/nested-awk-command]