#!/bin/sh
for i in $(seq 2020 1 2021); 
do
    for j in $(seq 1 1 4);
    do
        idx_file="https://www.sec.gov/Archives/edgar/full-index/$i/QTR$j/form.idx"
        if curl -o /dev/null --silent --fail --head $idx_file; then
            echo "Reading idx file for $i-QTR$j"
            dir_date=$(echo $idx_file | sed -rne "s|.*([0-9]{4})/QTR([1-4]).*|\1-QTR\2|p")
            curl -s $idx_file | grep -E "^4[[:space:]]" | 
            awk -v home_link="https://www.sec.gov/Archives/" 'BEGIN{OFS=":"; ORS="\n"}
                {for(i=2;i<NF-2;i++) printf("%s ", $(i))
                print "", $(NF-2), $(NF - 1), home_link$(NF)}' |
            while IFS=: read -r company cik date link; do
                sleep 0.1001
                xml_file=`curl -s $link | sed -ne '0,/<FILENAME>/s/<FILENAME>\(.*\)/\1/p' `
                temp=`echo $link | sed -e 's/-//g'`
                new_link=`echo $temp | sed -e "s|.txt|/$xml_file|"`
                printf "%s\b|%s|%s|%s\n" "${company}" $cik $date $new_link; 
            done >trading_$dir_date.csv
        else
            echo "No index file for $i-QTR$j"
        fi
    done
done;

files=$(find . -name "trading_*" -print);
echo "Company|CIK|Date|XML Link" >data.csv
for file in $files; do
    cat $file >> data.csv
    echo "$file is appended into database document"
    rm $file
done

# https://stackoverflow.com/questions/4286469/how-to-parse-a-csv-file-in-bash
# sed the first occurence https://stackoverflow.com/questions/148451/how-to-use-sed-to-replace-only-the-first-occurrence-in-a-file
# check if an url exists https://stackoverflow.com/questions/12199059/how-to-check-if-an-url-exists-with-the-shell-and-probably-curl