#!/bin/bash
non_xml=$(wc -l < form4_data_temp.csv)

while :
do
    sed -i 's/|/::/g' form4_data_temp.csv
    bash extract_recover.sh
    wait
    cat form4_recover.csv | grep "xml$" >> form4_data_xml.csv
    cat form4_recover.csv | grep -Ev "(xml$)|(htm$)|(txt$)" >form4_data_temp.csv
    cat form4_recover.csv | grep "htm$" >> form4_data_htm.csv
    cat form4_recover.csv | grep "txt$" >> form4_data_txt.csv;
    >form4_recover.csv;
    new_non_xml=$(wc -l < form4_data_temp.csv)
    echo "new_non_xml="$new_non_xml
    echo "non_xml="$non_xml
    if (( $non_xml > $new_non_xml )); then
        non_xml=$new_non_xml
    else
        break
    fi
done

rm form4_recover.csv

# Remaining files will be retained in txt form
keepAsTxt() {
    txt_link=$(echo $4 | sed -re 's|(.*)/([0-9]*)/([0-9]{10})([0-9]{2})([0-9]{6})/|\1/\2/\3\4\5/\3-\4-\5.txt|')
    printf "%s\b|%s|%s|%s\n" "$1" $2 $3 $txt_link;
    sleep 1;
}
export -f keepAsTxt

sed -i 's/|/::/g' form4_data_temp.csv
awk '{print $0}' form4_data_temp.csv |
    /usr/local/bin/parallel -j10 --keep-order --col-sep :: -a - keepAsTxt ">>" form4_data_txt.csv;