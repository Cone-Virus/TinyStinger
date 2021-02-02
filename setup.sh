#!/bin/bash

chmod +x scanner.sh
mkdir Tools
git clone https://github.com/maurosoria/dirsearch.git Tools/dirsearch
git clone https://github.com/EnableSecurity/wafw00f Tools/wafw00f
git clone https://github.com/ChrisKnott/Eel Tools/Eel
sudo pip3 install -r Tools/dirsearch/requirements.txt
cd Tools/wafw00f/
sudo python3 setup.py build
sudo python3 setup.py install
cd ../..
cd Tools/Eel/
sudo python3 setup.py build
sudo python3 setup.py install
sudo pip3 install eel
cd ../..
