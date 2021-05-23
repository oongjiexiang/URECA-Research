#!/bin/bash
read CIKs;
user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"

scrapDetailsFromLink() {
    temp=$(echo $4 | sed -e 's/-//g');
    xml_file=$(curl -A $user_agent -s $4 | sed -ne '0,/<FILENAME>/s/<FILENAME>\(.*\)/\1/p');
    new_link=$(echo $temp | sed -e "s|.txt|/$xml_file|");
    printf "%s\b|%s|%s|%s\n" "$1" $2 $3 $new_link;
    sleep 1;
}
export -f scrapDetailsFromLink

for i in $(seq 1993 1 2020); 
do
    for j in $(seq 1 1 4);
    do
        idx_file="https://www.sec.gov/Archives/edgar/full-index/$i/QTR$j/form.idx"
        if curl -A $user_agent -o /dev/null --silent --fail --head $idx_file; then
            echo "Reading idx file for $i-QTR$j" | tee -a extract_link_log.txt;
            SECONDS=0;
            dir_date=$(echo $idx_file | sed -rne "s|.*([0-9]{4})/QTR([1-4]).*|\1-QTR\2|p")
            curl -A $user_agent -s $idx_file | grep -E "^4[[:space:]]" | grep -Ew $CIKs |
            awk -v home_link="https://www.sec.gov/Archives/" 'BEGIN{OFS="::"; ORS="\n"}
                {for(i=2;i<NF-2;i++) printf("%s ", $(i))
                print "", $(NF-2), $(NF - 1), home_link$(NF)}' |
            /usr/local/bin/parallel -j10 --keep-order --col-sep :: -a - scrapDetailsFromLink ">>" trading_$dir_date.csv
            echo "Runtime for $i-QTR$j: $SECONDS" >>extract_link_log.txt
        else
            echo "No index file for $i-QTR$j" >>extract_link_log.txt
        fi
    done
done;

files=$(find . -name "trading_*" -print);
for file in $files; do
    cat $file >> form4_data.csv
    echo "$file is appended into database document"
    rm $file
done;

# Categorise files according to extension
echo "Categorising files according to extension" | tee -a extract_link_log.txt
echo "Company|CIK|Date|XML Link" | form4_data_xml.csv form4_data_txt.csv form4_data_htm.csv
cat form4_data.csv | grep "xml$" >>form4_data_xml.csv
cat form4_data.csv | grep "txt$" >>form4_data_txt.csv
cat form4_data.csv | grep "htm$" >>form4_data_htm.csv
cat form4_data.csv | grep -Ev "(xml$)|(htm$)|(txt$)" >form4_data_temp.csv

# recover files that are not retrieved in the first trial
echo "Recovering files" | tee -a extract_link_log.txt
bash recover.sh

# https://stackoverflow.com/questions/4286469/how-to-parse-a-csv-file-in-bash
# sed the first occurence https://stackoverflow.com/questions/148451/how-to-use-sed-to-replace-only-the-first-occurrence-in-a-file
# check if an url exists https://stackoverflow.com/questions/12199059/how-to-check-if-an-url-exists-with-the-shell-and-probably-curl