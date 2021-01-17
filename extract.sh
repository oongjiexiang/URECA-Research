#!/bin/sh
idx_file=$1;
curl $idx_file | grep -E "^4[[:space:]]" | 
awk -v home_link="https://www.sec.gov/Archives/" 'BEGIN{OFS=":"; ORS="\n"}
    {for(i=2;i<NF-2;i++) printf("%s ", $(i))
    print "", $(NF-2), $(NF - 1), home_link$(NF)}' | 
while IFS=: read -r company cik date link; do
    xml_file=`curl -s $link | sed -ne '0,/<FILENAME>/s/<FILENAME>\(.*\)/\1/p' `
    temp=`echo $link | sed -e 's/-//g'`
    new_link=`echo $temp | sed -e "s|.txt|/$xml_file|"`
    printf "%s%b:%s:%s:%s\n" "${company}" $cik $date $new_link; 
done >trading_doc_db.csv

# read csv https://stackoverflow.com/questions/4286469/how-to-parse-a-csv-file-in-bash
# sed the first occurence https://stackoverflow.com/questions/148451/how-to-use-sed-to-replace-only-the-first-occurrence-in-a-file