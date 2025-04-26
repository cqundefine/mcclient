#!/bin/python3
import json

ids = {}

blocks = json.load(open("blocks.json"))
for key, value in blocks.items():
    print(f"{key}")
    for state in value["states"]:
        print(f" - {state["id"]}")
        ids[state["id"]] = key

json.dump(ids, open("block_ids.json", "w"))

ids = {}

registries = json.load(open("registries.json"))
for key, value in registries["minecraft:entity_type"]["entries"].items():
    print(f"{key}")
    print(f" - {value["protocol_id"]}")
    ids[value["protocol_id"]] = key

json.dump(ids, open("entity_type_ids.json", "w"))
