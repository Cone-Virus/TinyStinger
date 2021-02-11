#!/bin/bash

#Basic argument set
URLFILE=$1
wordlist="/usr/share/wordlists/dirb/common.txt"
exten=""
recursion="-n"
outlist=""
LTemp=""


echo "
▀█▀ █ █▄░█ █▄█   █▀ ▀█▀ █ █▄░█ █▀▀ █▀▀ █▀█
░█░ █ █░▀█ ░█░   ▄█ ░█░ █ █░▀█ █▄█ ██▄ █▀▄
Created by: @Cone_Virus
                         (\\\\
....-_...___-..-.._..-. -###)
                          \"\"
"

## Status Function
function stat(){
        if [[ $1 == 1 ]]
        then
                echo "Status: Scanning $1/$2 for $3..."
        else
                echo -e "\e[1A\e[KStatus: Scanning $1/$2 for $3..."
        fi
}

#Help Menu
function help_menu(){
        echo "Please give a URL List
Example: ./scanner.sh <URL List> <Options>

Options:

--General Options--
-GUI <BeeHive Loot>     : Load a Loot directory in BeeHive EX: BeeHive/LOOT-iSidt
-n <Lootdir Name>       : Name the loot directory the results are put into EX: MyNextBugBounty

--Scope Options--
-os <Out of Scope List> : Load a list of targets out of scope to be removed from target list

--Directory Scanning--
-w <Wordlist>           : Use a custom wordlist in directory scanning
-x <Extensions>         : Use a set of extensions in directory scanning EX: html,jpg,txt
-X <Extension List>     : Use a list of extensions in directory scanning"
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
if ! [[  -d "Tools/httprober"  &&  -d "Tools/wafw00f" ]]
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
                elif [ "$arg" == "-r" ]
                then
                        if [ "${args[$(($count + 1))]}" == "" ]
                        then
                                echo "No number provided"
                                help_menu
                        fi
                        if (("${args[$(($count + 1))]}" >= "0")) && (("${args[$(($count + 1))]}" <= "4"))
                        then
                                recursion="-d ${args[$(($count + 1))]}"
                        else
                                echo "Invalid number"
                                help_menu
                        fi
                elif [ "$arg" == "-os" ]
                then
                        if [ "${args[$(($count + 1))]}" == "" ]
                        then
                                echo "No out of scope list provided"
                                help_menu
                        fi
                        file_check "${args[$(($count + 1))]}" "Out of Scope List"
                        outlist="${args[$(($count + 1))]}"
                elif [ "$arg" == "-n" ]
                then
                        LTemp="${args[$(($count + 1))]}"
        fi
        count=$(($count+1))
done

file_check "$URLFILE" "URL List"

#Generate Temps
waflesstemp=$(mktemp WAFless-XXXXXX)
waftemp=$(mktemp WAF-XXXXXX)

#Lootdir naming
if [ "$LTemp" == "" ]
then
        LTemp=$(mktemp -u LOOT-XXXXX)
fi
lootdir=$(echo "BeeHive/$LTemp")
mkdir $lootdir/

#Setting extensions
if [ "$exten" == "" ]
then
        exten="php"
fi

echo "Reading List"

echo "Looking for Subdomains"
#Find subdomains here
temptemp=$(mktemp TEST-XXXXXX)
temptargets=$(mktemp TAR-XXXXXX)
cat $URLFILE > $temptargets
wildcards=$(cat $URLFILE | grep "*." | sed 's/*.//g')
for i in $wildcards
do
        sed -ir "s/$i//" $temptargets
        Tools/subfinder -d $i -o $temptemp 2>/dev/null
        cat $temptemp >> $temptargets
done

if [ "$outlist" != "" ]
then
        echo "Removing Out of Scope Targets"
        outofscope=$(cat $outlist)
        for i in $outofscope
        do
                sed -ir "s/$i//" $temptargets
        done
fi

#Validate targets
echo "Validating Targets"
list=$(cat $temptargets | sort | uniq | Tools/dnsx 2>/dev/null | Tools/httprober/httprober)
rm $temptemp
rm $temptargets

file=$list
count=1
total=$(echo $file | grep -o http | wc -l)
echo "Detecting WAF"
for i in $file
do
        stat $count $total "WAF" 
        request=$(python3 Tools/wafw00f/wafw00f/main.py $i 2>/dev/null | grep -w "WAF")
        sleep 2
        filter=$(echo $request | grep "No WAF")
        if [[ -z "$filter" ]]
        then
                echo $i >> $waftemp
        else
                echo $i >> $waflesstemp
        fi
        count=$(($count + 1))
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
        echo "                        \"dir\" : l\"$count\"" >> "Database.json"
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
        echo "                        \"url\" : \"$i\"," >> "Database.json"
        echo "                        \"dir\" : f\"$count\"" >> "Database.json"
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

#Scan wafless with dirsearch and organizing said file
echo "Running Dirsearch on WAFLess"
count=0
counter=1
file=$(cat $waflesstemp)
total=$(awk /./ $waflesstemp | wc -l)
for i in $file
do
        stat $counter $total "Directories"
        temp=$(echo "${i//\/}")
        Tools/ffuf  -u "$i""/FUZZ" -w "$wordlist" -e "$exten" -of 'html' -o "$temp" 2>/dev/null
        cat $temp | grep -v "<pre>.*</pre>" >> "$lootdir/$temp-Directory-Results"
        sed -ir "s/\"dir\" : l\"$count\"/\"dir\" : \"$temp-Directory-Results\"/" "$lootdir/Database.json"
        count=$(($count + 1))
        counter=$(($counter + 1))
        rm $temp
        rm "$lootdir/Database.jsonr"
done

## Demo fo Waffull targets
echo "Dummy File<br>" > "$lootdir/dummyfile"
count=0
counter=1
file=$(cat $waftemp)
total=$(awk /./ $waftemp | wc -l)
for i in $file
do
        sed -ir "s/\"dir\" : f\"$count\"/\"dir\" : \"dummyfile\"/" "$lootdir/Database.json"
        rm "$lootdir/Database.jsonr"
        count=$(($count + 1))
done

#Delete temp files
rm $waftemp
rm $waflesstemp
rm ferox-* 2>/dev/null

#Deploy GUI
echo "Deploying GUI"
python3 StingerGUI.py $lootdir
