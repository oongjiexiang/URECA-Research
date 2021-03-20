#!/bin/bash
# successful
# generates the dummy dataset to explain the section for 'Rationale for Using Scripting'

echo "digit_1,mul2,digit_2,digit_3,digit_4,digit_5,mod3,mod5,doubledigit_1,digit_6,digit_7,digit_8,mod4,doubledigit_2,digit_9,digit_10,digit_11,mod7,triple,doubledigit_3,digit12,digit13,digit14" | tee test1.csv
for i in $(seq 1 1 50000000); do 
    tmp=$(($i%10));
    echo $tmp,$(($(($i*2))%10)),$tmp,$tmp,$tmp,$tmp,$(($tmp % 3)),$(($tmp % 5)),$tmp$tmp,$tmp,$tmp,$tmp,$(($tmp % 4)),$tmp$tmp,$tmp,$tmp,$tmp,$(($tmp % 7)),$tmp$tmp$tmp,$tmp$tmp,$tmp,$tmp,$(($tmp % 4)); 
done | tee -a test1.csv | awk 'FNR < 10'