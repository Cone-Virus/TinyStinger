#!/bin/bash

URLFILE=$1
wordlist="dirsearch/db/dicc.txt"

echo "
▀█▀ █ █▄░█ █▄█   █▀ ▀█▀ █ █▄░█ █▀▀ █▀▀ █▀█
░█░ █ █░▀█ ░█░   ▄█ ░█░ █ █░▀█ █▄█ ██▄ █▀▄
Created by: @Cone_Virus
                         (\\\\
....-_...___-..-.._..-. -###)
                          \"\"
"

function help_menu(){
        echo "Please give a URL List
Example: ./scanner.sh <URL List>

Options:
-w <Wordlist> : Use a custom wordlist in directory scanning"
        exit 0
}

function file_check(){
        if [ -f $1 ]; 
        then
                if [ ! -r $1 ]
                then
                        echo "Can't read the file $1"
                        help_menu
                fi
        else
                echo "$1 is not a valid $2"
                help_menu
        fi

}

if [ ! -d "dirsearch" ] || [ ! -d "wafw00f" ]
then
        echo "Please run the setup script with the following commands before using the scanner:
chmod +x setup.sh
./setup.sh"
        exit 0
fi

if [[ $# == 0 ]] 
then
        help_menu
fi

args=("$@")
count=0
for arg in "$@"
do
        if [ "$arg" == "--help" ] || [ "$arg" == "-h" ] 
        then
                        help_menu
                elif [ "$arg" == "-w" ]
                then
                        if [ "${args[$(($count + 1))]}" == "" ]
                        then
                                echo "No wordlist provided"
                                help_menu
                        else
                                file_check "${args[$(($count + 1))]}" "wordlist"
                                wordlist="${args[$(($count + 1))]}" 
                        fi
        fi
        count=$(($count+1))
done

file_check "$URLFILE" "URL List"


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
dirsearch/dirsearch.py -l $waflesstemp -w $wordlist -e php,html,js,txt --plain-text=$dirtemp

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
