#!/bin/bash

chmod +x scanner.sh
git clone https://github.com/maurosoria/dirsearch.git
sudo pip3 install -r requirements.txt
git clone https://github.com/EnableSecurity/wafw00f
sudo python3 wafw00f/setup.py
