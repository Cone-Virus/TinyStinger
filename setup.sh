#!/bin/bash

chmod +x scanner.sh
git clone https://github.com/maurosoria/dirsearch.git
git clone https://github.com/EnableSecurity/wafw00f
git clone https://github.com/ChrisKnott/Eel
sudo pip3 install -r dirsearch/requirements.txt
cd wafw00f/
sudo python3 setup.py build
sudo python3 setup.py install
cd ..
cd Eel/
sudo python3 setup.py build
sudo python3 setup.py install
sudo pip3 install eel
cd ..
