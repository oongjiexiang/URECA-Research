#!/bin/bash
user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36"

recoverFile() {
    txt_link=$(echo $4 | sed -re 's|(.*)/([0-9]*)/([0-9]{10})([0-9]{2})([0-9]{6})/|\1/\2/\3\4\5/\3-\4-\5.txt|')
    temp=$4;
    xml_file=$(curl -s $txt_link | sed -ne '0,/<FILENAME>/s/<FILENAME>\(.*\)/\1/p');
    new_link=$temp""$xml_file;
    printf "%s\b|%s|%s|%s\n" "$1" $2 $3 $new_link;
    sleep 1;
}
export -f recoverFile

awk '{print $0}' form4_data_temp.csv |
    /usr/local/bin/parallel -j10 --keep-order --col-sep :: -a - recoverFile ">>" form4_recover.csv;


# echo "https://www.sec.gov/Archives/edgar/data/96021/000120919118040077/" | sed -re 's|(.*)/([0-9]*)/([0-9]{10})([0-9]{2})([0-9]{6})/|\1/\2/\3\4\5/\3-\4-\5.txt'
# echo "https://www.sec.gov/Archives/edgar/data/96021/000120919118040077/" | sed -re 's|(.*)/([0-9]*)/([0-9]{10})([0-9]{2})([0-9]{6})/|\1/\2/\3\4\5/\3-\4-\5.txt'
#txt_link = $(echo "https://www.sec.gov/Archives/edgar/data/96021/000120919118040077/" | sed -re 's|(.*)/([0-9]*)/([0-9]{10})([0-9]{2})([0-9]{6})/|\1/\2/\3\4\5/\3-\4-\5.txt|')