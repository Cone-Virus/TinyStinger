#!/bin/bash

#Basic argument set
URLFILE=$1
wordlist="dirsearch/db/dicc.txt"
exten=""



echo "
▀█▀ █ █▄░█ █▄█   █▀ ▀█▀ █ █▄░█ █▀▀ █▀▀ █▀█
░█░ █ █░▀█ ░█░   ▄█ ░█░ █ █░▀█ █▄█ ██▄ █▀▄
Created by: @Cone_Virus
                         (\\\\
....-_...___-..-.._..-. -###)
                          \"\"
"

#Help Menu
function help_menu(){
        echo "Please give a URL List
Example: ./scanner.sh <URL List> <Options>

Options:
-GUI <BeeHive Loot> : Load a Loot directory in BeeHive EX: BeeHive/LOOT-iSidt
-w <Wordlist>       : Use a custom wordlist in directory scanning
-x <Extensions>     : Use a set of extensions in directory scanning EX: html,jpg,txt
-X <Extension List> : Use a list of extensions in directory scanning"
        exit 0
}

#Validates the existence of a text file
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

#Simple check to see if setup.sh was run
if ! [[  -d "dirsearch"  &&  -d "wafw00f" ]]
then
        echo "Please run the setup script with the following commands before using the scanner:
chmod +x setup.sh
./setup.sh"
        exit 0
fi

#If none supplied print a menu
if [[ $# == 0 ]] 
then
        help_menu
fi

#Arguments for scanner
args=("$@")
count=0
for arg in "$@"
do
        if [ "$arg" == "--help" ] || [ "$arg" == "-h" ] 
        then
                        help_menu
                elif [ "$arg" == "-GUI" ]
                then
                        if [ -d ${args[$(($count + 1))]} ]
                        then
                                echo "Deploying GUI"
                                python3 StingerGUI.py ${args[$(($count + 1))]}
                                exit 0
                        else
                                echo "Invalid path or loot dir in BeeHive"
                                help_menu
                        fi
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
                                exten=$(awk /./ "${args[$(($count + 1))]}" | sed ':a;N;$!ba;s/\n/,/g')
                        else
                                echo "Can't set extensions more then once"
                                help_menu
                        fi
        fi
        count=$(($count+1))
done

file_check "$URLFILE" "URL List"

#Generate Temps
waflesstemp=$(mktemp WAFless-XXXXXX)
waftemp=$(mktemp WAF-XXXXXX)
LTemp=$(mktemp -u LOOT-XXXXX)
lootdir=$(echo "BeeHive/$LTemp")
mkdir $lootdir/

if [ "$exten" == "" ]
then
        exten="php,html,js,txt"
fi

echo "Reading List"

# Scan for WAF on target
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

#Display WAF Results
echo "WAF results"
echo "-- WAFLess --" 
cat $waflesstemp 
echo "-- WAFFull --" 
cat $waftemp 

#Generate Database.json
echo "Creating JSON DB"

number1=$(awk /./  $waflesstemp | wc -l | awk '{ print $1 }')
number2=$(awk /./  $waftemp | wc -l | awk '{ print $1 }')
echo "{" >> "Database.json"
echo "        \"loot\": \"$LTemp\"," >> "Database.json" 
echo "        \"less\": [" >> "Database.json"

count=0
file=$(cat "$waflesstemp")
for i in $file
do
        echo "                {" >> "Database.json"
        echo "                        \"url\" : \"$i\"," >> "Database.json"
        echo "                        \"dir\" : \"$count\"" >> "Database.json"
        if [[ $count -eq $(($number1 - 1)) ]]
        then
                echo "                }" >> "Database.json"
        else
                echo "                }," >> "Database.json"
        fi
        count=$((count + 1))
done

echo "        ]," >> "Database.json"

echo "        \"full\": [" >> "Database.json"

count="0"
file=$(cat $waftemp)
for i in $file
do
        echo "                {" >> "Database.json"
        echo "                        \"url\" : \"$i\"" >> "Database.json"
        if [[ $count != $(($number2 - 1)) ]]
        then
                echo "                }," >> "Database.json"
        else
                echo "                }" >> "Database.json"
        fi
        count=$(($count + 1))
done

echo "        ]" >> "Database.json"
echo "}" >> "Database.json"


mv "Database.json" "$lootdir"

#Scan wafless with dirsearch
echo "Running Dirsearch on WAFLess"
file=$(cat $waflesstemp)
for i in $file
do
        temp=$(echo "${i//\/}")
        dirsearch/dirsearch.py -u "$i" -w "$wordlist" -e "$exten" --plain-text="$temp"
done

#Organizes the results into an easier to read formfactor and stores it into lootdir aswell as adds it
#To the Database.json
count=0
echo "Ordering per URL"
file=$(cat $waflesstemp)
for i in $file
do
        temp=$(echo "${i//\/}")
        echo "Results for $i<br>" >> "$lootdir/$temp-Directory-Results"
        echo "------------------------------------<br>" >> "$lootdir/$temp-Directory-Results"
        cat $temp | grep $i | grep -v 503 | awk '{print $0,"<br>"}' >> "$lootdir/$temp-Directory-Results"
        sed -ir "s/\"dir\" : \"$count\"/\"dir\" : \"$temp-Directory-Results\"/" "$lootdir/Database.json"
        count=$(($count + 1))
        rm $temp
        rm "$lootdir/Database.jsonr"
done

#Delete temp files
rm $waftemp
rm $waflesstemp

#Deploy GUI
echo "Deploying GUI"
python3 StingerGUI.py $lootdir
