#!/bin/sh
# in case
# used to remove \r characters if Windows accidentally converted LF to CRLF
files=$(find . -name "*.sh" -print)
for file in $files; do
    original_file=$file
    mv $file ${file}temp.sh
    cat ${file}temp.sh | tr -d '\r' | cat >${original_file}
    rm ${file}temp.sh
    echo ${original_file} is processed
done