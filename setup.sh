#!/bin/bash

chmod +x scanner.sh
mkdir Tools
git clone https://github.com/tomnomnom/httprobe Tools/httprober
curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/master/install-nix.sh | bash
mv feroxbuster Tools/
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
cd ../..
sudo apt install -y golang
cd Tools/httprober
go build main.go
mv main httprober
cd ../..
