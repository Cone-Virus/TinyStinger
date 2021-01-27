#!/bin/bash

URLFILE=$1
wordlist="dirsearch/db/dicc.txt"
exten=""
OLDIFS="$IFS"
IFS="
"

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
Example: ./scanner.sh <URL List> <Options>

Options:
-w <Wordlist>       : Use a custom wordlist in directory scanning
-x <Extensions>     : Use a set of extensions in directory scanning EX: html,jpg,txt
-X <Extension List> : Use a list of extensions in directory scanning"
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
                elif [ "$arg" == "-x" ]
                then
                        if [ "${args[$(($count + 1))]}" == "" ]
                        then
                                echo "No extensions provided"
                                help_menu
                        fi
                        if [ "$exten" == "" ]
                        then
                                exten="${args[$(($count + 1))]}"
                        else
                                echo "Can't set extensions more then once"
                                help_menu
                        fi
                elif [ "$arg" == "-X" ]
                then
                        if [ "${args[$(($count + 1))]}" == "" ]
                        then
                                echo "No extensions list provided"
                                help_menu
                        fi
                        if [ "$exten" == "" ]
                        then
                                file_check "${args[$(($count + 1))]}" "extension list"
                                truncate -s -1 "${args[$(($count + 1))]}"
                                exten=$(cat "${args[$(($count + 1))]}" | sed ':a;N;$!ba;s/\n/,/g')
                        else
                                echo "Can't set extensions more then once"
                                help_menu
                        fi
        fi
        count=$(($count+1))
done

file_check "$URLFILE" "URL List"


waflesstemp=$(mktemp WAFless-XXXXXX)
waftemp=$(mktemp WAF-XXXXXX)
lootdir=$(mktemp -u LOOT-XXXXX)
mkdir $lootdir/

if [ "$exten" == "" ]
then
        exten="php,html,js,txt"
fi

echo "Reading List"

file=$(cat $1)
echo "Detecting WAF"
for i in $file
do
        request=$(python3 wafw00f/wafw00f/main.py $i |  grep -w WAF)
        sleep 2
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
mv "WAF-Results" "$lootdir"

echo "Running Dirsearch on WAFLess"
file=$(cat $waflesstemp)
for i in $file
do
        temp=$(echo "${i//\/}")
        dirsearch/dirsearch.py -u "$i" -w "$wordlist" -e "$exten" --plain-text="$temp"
done

echo "Ordering per URL"
file=$(cat $waflesstemp)
for i in $file
do
        temp=$(echo "${i//\/}")
        echo "Results for $i" >> "$lootdir/$temp-Directory-Results"
        echo "------------------------------------" >> "$lootdir/$temp-Directory-Results"
        cat $temp | grep $i | grep -v 503 >> "$lootdir/$temp-Directory-Results"
        rm $temp
done

rm $waftemp
rm $waflesstemp

yadb=0
while [ $yadb -eq "0" ];do 
    fc=$(basename -s -Directory-Results $(find $lootdir/ -name "*-Directory-Results") |yad --list --width=500 --height=500 --center --column="WAFless Directory Results" --separator="")
    yadb=$?
    if [ $yadb -eq "0" ]; then 
       cat $lootdir/$fc-Directory-Results |yad --text-info --width=800 --height=300
    fi
done
