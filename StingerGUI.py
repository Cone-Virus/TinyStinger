import eel, os, json, sys

#open and store database.json
location = sys.argv[1]

with open(f"{location}/Database.json", "r") as f:
       data = json.load(f)
 
loot = data['loot']

#Return list of waf or wafless
@eel.expose
def waf_select(waf):
    urls = []
    for i in data[waf]:
        urls.append(i['url'])

    return urls

#Return list of selected results
@eel.expose
def url_select(waf, opt):
    urls = []
    for i in data[waf]:
        temp = loot + '/' + i[opt]
        urls.append(temp)

    return urls
    
#Deploy Eel Server
eel.init('BeeHive')
eel.start('Stinger.html',mode='firefox') 
