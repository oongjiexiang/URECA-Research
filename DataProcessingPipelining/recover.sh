#!/bin/bash
num_xml=$(wc -l form4_data_temp.csv)

while :
do
    sed -i 's/|/::/g' form4_data_temp.csv
    bash extract_recover.sh
    cat form4_recover.csv | grep "xml$" >> ../Database/form4_data_xml.csv
    cat form4_recover.csv | grep -Ev "(xml$)|(htm$)|(txt$)" >form4_data_temp.csv
    cat form4_recover.csv | grep "htm$" >> ../Database/form4_data_htm.csv
    cat form4_recover.csv | grep "txt$" >> ../Database/form4_data_txt.csv
    rm form4_recover.csv
    num_new_xml=$(wc -l form4_data_temp.csv)
    if [$num_xml -gt $num_new_xml]; then
        $num_xml=$num_new_xml
    else
        break
    fi
done