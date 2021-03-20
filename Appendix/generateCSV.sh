#!/bin/bash
# successful

echo "Approach 1: without saving to a file, use tee to send output to head" >tee_head_time.csv
for ((row_size = 10; row_size < 70; row_size*=10)) do
    start=$(($(date +%s%N)/1000000));
    echo "digit_1,mul2,digit_2,digit_3,digit_4,digit_5,mod3,mod5,doubledigit_1,digit_6,digit_7,digit_8,mod4,doubledigit_2,digit_9,digit_10,digit_11,mod7,triple,doubledigit_3,digit12,digit13,digit14"
    for i in $(seq 1 1 $row_size); do 
        tmp=$(($i%10));
        echo $tmp,$(($(($i*2))%10)),$tmp,$tmp,$tmp,$tmp,$(($tmp % 3)),$(($tmp % 5)),$tmp$tmp,$tmp,$tmp,$tmp,$(($tmp % 4)),$tmp$tmp,$tmp,$tmp,$tmp,$(($tmp % 7)),$tmp$tmp$tmp,$tmp$tmp,$tmp,$tmp,$(($tmp % 4)); 
    done | tee | head 
    end=$(($(date +%s%N)/1000000))
    echo $row_size: $(($end-$start)) >>tee_head_time.csv
done;

echo "Approach 2: save output in a file, then use head utility" >>tee_head_time.csv
for ((row_size = 10; row_size < 70; row_size*=10)) do
    start=$(($(date +%s%N)/1000000));
    echo "digit_1,mul2,digit_2,digit_3,digit_4,digit_5,mod3,mod5,doubledigit_1,digit_6,digit_7,digit_8,mod4,doubledigit_2,digit_9,digit_10,digit_11,mod7,triple,doubledigit_3,digit12,digit13,digit14" >test.csv
    for i in $(seq 1 1 $row_size); do 
        tmp=$(($i%10));
        echo $tmp,$(($(($i*2))%10)),$tmp,$tmp,$tmp,$tmp,$(($tmp % 3)),$(($tmp % 5)),$tmp$tmp,$tmp,$tmp,$tmp,$(($tmp % 4)),$tmp$tmp,$tmp,$tmp,$tmp,$(($tmp % 7)),$tmp$tmp$tmp,$tmp$tmp,$tmp,$tmp,$(($tmp % 4)); 
    done >>test.csv
    head test.csv
    end=$(($(date +%s%N)/1000000))
    echo $row_size: $(($end-$start)) >>tee_head_time.csv
    rm test.csv;
done;