import requests
import json
#import pandas

def find_monster():
    responseList = requests.get("https://api.open5e.com/monsters/?search=fir")
    monsterList = responseList.json()
    for i in range(len(monsterList["results"])):
        print(monsterList["results"][i]["slug"], "\n")

find_monster()