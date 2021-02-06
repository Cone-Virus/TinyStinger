## TinyStinger
- What is it?

A small Bug Bounty scanner that I have been working on to not only make doing bug bounties easier but to help other small bug bounty enthuasiasts.
- Keep in mind

I am not an expert coder so there will probably be a ton of bugs and if something bad happens to your system I am not liable. But nothing should just a quick disclaimer. --Dirbuster may break your VM until further notice I am looking for an alternative--
## Usage 
- Before first use do the following:
```
chmod +x setup.sh
./setup.sh
```
- Usage
```
./scanner.sh -h

▀█▀ █ █▄░█ █▄█   █▀ ▀█▀ █ █▄░█ █▀▀ █▀▀ █▀█
░█░ █ █░▀█ ░█░   ▄█ ░█░ █ █░▀█ █▄█ ██▄ █▀▄
Created by: @Cone_Virus
                         (\\
....-_...___-..-.._..-. -###)
                          ""

Please give a URL List
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
-X <Extension List>     : Use a list of extensions in directory scanning
-r <Depth>              : Enable recursion and at what depth (0 is infinite) (1-4) EX: -r 3
```
## TODO
- [x] Add A GUI
- [x] Make a better GUI
- [ ] Make it look nice with more options
- [ ] Add way more tooling
- [x] Give this tool a better name or keep it (Keeping it)
- [x] Add a way for list of extensions 
- [ ] Make a better readme
## Credits
This tool is a combination of others marvelous code so of course I have a credits for each tool used
## Contributors
[@zpaav](https://github.com/zpaav) for all the testing, tips, and all the web help
