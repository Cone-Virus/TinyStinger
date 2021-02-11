#!/bin/bash

chmod +x scanner.sh
mkdir Tools
git clone https://github.com/ffuf/ffuf Tools/ffuf-dir
git clone https://github.com/projectdiscovery/dnsx.git Tools/dnsx-dir
git clone https://github.com/projectdiscovery/subfinder.git Tools/subfinder-dir
git clone https://github.com/tomnomnom/httprobe Tools/httprober
git clone https://github.com/EnableSecurity/wafw00f Tools/wafw00f
git clone https://github.com/ChrisKnott/Eel Tools/Eel
cd Tools/wafw00f/
sudo python3 setup.py build
sudo python3 setup.py install
cd ../..
cd Tools/Eel/
sudo python3 setup.py build
sudo python3 setup.py install
sudo pip3 install eel
sudo pip3 -r requirements.txt
sudo pip3 -r requirements-meta.txt
cd ../..
sudo apt install -y golang
cd Tools/httprober
go build main.go
mv main httprober
cd ../..
cd Tools/subfinder-dir/v2/cmd/subfinder
go build .
mv subfinder ../../../../.
cd ../../../../..
cd Tools/dnsx-dir/cmd/dnsx
go build
mv dnsx ../../../.
cd ../../../..
cd Tools/ffuf-dir
go get
go build
mv ffuf ../.
cd ../../..
