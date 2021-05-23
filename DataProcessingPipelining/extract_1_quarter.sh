#!/bin/bash
read CIKs;
user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"

scrapDetailsFromLink() {
    temp=$(echo $4 | sed -e 's/-//g');
    xml_file=$(curl -s $4 | sed -ne '0,/<FILENAME>/s/<FILENAME>\(.*\)/\1/p');
    if [[ $? == 0 ]]; then
        new_link=$(echo $temp | sed -e "s|.txt|/$xml_file|");
        printf "%s\b|%s|%s|%s\n" "$1" $2 $3 $new_link;
    else
        printf "%s\b|%s|%s|%s\n" "$1" $2 $3 $temp;
    fi
    sleep 1;
}
export -f scrapDetailsFromLink

for i in $(seq 2010 1 2010); 
do
    for j in $(seq 1 1 1);
    do
        idx_file="https://www.sec.gov/Archives/edgar/full-index/$i/QTR$j/form.idx"
        if curl -A $user_agent -o /dev/null --silent --fail --head $idx_file; then
            echo "Reading idx file for $i-QTR$j"
            SECONDS=0;
            dir_date=$(echo $idx_file | sed -rne "s|.*([0-9]{4})/QTR([1-4]).*|\1-QTR\2|p")
            curl -s $idx_file | grep -E "^4[[:space:]]" | grep -Ew $CIKs |
            awk -v home_link="https://www.sec.gov/Archives/" 'BEGIN{OFS="::"; ORS="\n"}
                {for(i=2;i<NF-2;i++) printf("%s ", $(i))
                print "", $(NF-2), $(NF - 1), home_link$(NF)}' |
            /usr/local/bin/parallel -j10 --keep-order --col-sep :: -a - scrapDetailsFromLink ">>" trading_$dir_date.csv
            echo "Runtime for $i-QTR$j: $SECONDS"
        else
            echo "No index file for $i-QTR$j"
        fi
    done
done;

files=$(find . -name "trading_*" -print);
echo "Company|CIK|Date|XML Link" >>form4_data.csv
for file in $files; do
    cat $file >> form4_data.csv
    echo "$file is appended into database document"
    rm $file
done;

# https://stackoverflow.com/questions/4286469/how-to-parse-a-csv-file-in-bash
# sed the first occurence https://stackoverflow.com/questions/148451/how-to-use-sed-to-replace-only-the-first-occurrence-in-a-file
# check if an url exists https://stackoverflow.com/questions/12199059/how-to-check-if-an-url-exists-with-the-shell-and-probably-curl