#!/bin/bash

URLFILE=$1
waflesstemp=$(mktemp WAFless-XXXXXX)
waftemp=$(mktemp WAF-XXXXXX)
dirtemp=$(mktemp DIR-XXXXXX)

echo "Reading List"

file=$(cat $1)
echo "Detecting WAF"
for i in $file
do
        request=$(python3 wafw00f/wafw00f/main.py $i |  grep -w WAF)
        filter=$(echo $request | grep "No WAF")
        if [[ -z "$filter" ]]
        then
                echo $i >> $waftemp
        else
                echo $i >> $waflesstemp
        fi
done

echo "Saving WAF results"
echo "-- WAFLess --" >> "WAF-Results"
cat $waflesstemp >> "WAF-Results"
echo "-- WAFFull --" >> "WAF-Results"
cat $waftemp >> "WAF-Results"

echo "WAF Results"
cat "WAF-Results"

echo "Running Dirsearch on WAFLess"
dirsearch/dirsearch.py -l $waflesstemp -e php,html,js,txt --plain-text=$dirtemp

echo "Ordering per URL"
file=$(cat $waflesstemp)
for i in $file
do
        echo "Results for $i" >> "Directory-Results"
        echo "------------------------------------" >> "Directory-Results"
        cat $dirtemp | grep $i | grep -v 503 >> "Directory-Results"
done

rm $dirtemp
rm $waftemp
rm $waflesstemp
