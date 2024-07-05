import sys
import json
import xmltodict

json_params_str = sys.argv[1].replace("\n", "")
params = json.loads(json_params_str)

def read_data_from_file(file_path, file_type, dig_data):
    with open(file_path, 'r') as file:
        content = file.read()
    data = []
    if file_type == 'xml':
        data = xmltodict.parse(content)
    elif file_type == 'json': 
        data = json.loads(content)
    else:
        return data

    if dig_data != None:
        for key in dig_data:
            data = data[key]

    return data

def rename_colum_for_data(data, origin_name, new_name):
    for item in data:
        item[new_name] = item[origin_name]
        del item[origin_name]

def add_shop_name_for_data(data, shop_name):
    for item in data:
        item['shop_name'] = shop_name

data = []
# ["shop_name":"Cats Unlimited","file_type":"json","file_path":"./cats_unlimited.json", "dig_data": ['cats'], "rename_columns": {"img": "image"}}]
for shop in params['shops']:
    temp_data = read_data_from_file(shop['file_path'], shop['file_type'], shop.get('dig_data') )
    if shop.get('rename_columns') != None:
        for origin_name, new_name in shop.get('rename_columns').items():
            rename_colum_for_data(temp_data, origin_name, new_name)

    add_shop_name_for_data(temp_data, shop['shop_name'])
    data = data + temp_data
    
if params.get('cat_name') != None:
    data = [item for item in data if params['cat_name'].lower() in item.get('name').lower()]

for item in data:
    item['price'] = int(item['price'])

data.sort(key=lambda x: x['price'])

json_str = json.dumps(data[0])

print(json_str)
