#!/bin/sh
files=$(find . -name "trading_*" -print);
echo "Company|CIK|Date|XML Link" >data.csv
for file in $files; do
    cat $file >> data.csv
    echo "$file is appended into database document"
    rm $file
done