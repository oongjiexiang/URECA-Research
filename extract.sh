#!/bin/sh
read idx_file;
curl $idx_file | grep -E "^4[[:space:]]" | 
awk -v home_link="https://www.sec.gov/Archives/" 'BEGIN{ORS=""; OFS=", "}
    {fieldNum = NF;
    for(i=2;i<fieldNum-2;i++) print $(i) " "
    print $(fieldNum-2)
    print ", " $(fieldNum - 1), home_link $(fieldNum) "\n"}' | 
while IFS=, read -r company date link; do
    xml_file=`curl -s $link | sed -ne 's/<FILENAME>\(.*\)/\1/p' `
    temp=`echo $link | sed -e 's/-//g'`
    new_link=`echo $temp | sed -e 's|.txt|/$xml_file|'`
    echo $company "," $date "," $new_link
done >buffer2.txt
# read csv https://stackoverflow.com/questions/4286469/how-to-parse-a-csv-file-in-bash