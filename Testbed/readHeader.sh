#!/bin/bash

awk -v selectors=$1 'BEGIN {
    FS="|"; col_size = 0; getline; 
    n = split(selectors, select, "|");
    for(i = 1; i <= n; i++){
        for(j = 1; j <= NF; j++){
            if(select[i] == $j){
                col[col_size++] = j;
            }
        }
    }
    for(i = 0; i < length(col) - 1; i++){   printf "%s|", $col[i]   }
    print $col[length(col_size)]
}
{
    for(i = 0; i < length(col) - 1; i++){   printf "%s|", $col[i]   }
    print $col[length(col_size)]
}


' data_test.csv >data_out.csv

# split command [https://stackoverflow.com/questions/23763046/nested-awk-command]