#!/bin/bash

chmod +x scanner.sh
git clone https://github.com/maurosoria/dirsearch.git
sudo pip3 install -r dirsearch/requirements.txt
git clone https://github.com/EnableSecurity/wafw00f
cd wafw00f/
sudo python3 setup.py build
sudo python3 setup.py install
cd ..
