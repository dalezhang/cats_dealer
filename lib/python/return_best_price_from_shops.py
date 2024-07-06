import sys
import json
import xmltodict
import pandas as pd

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


df = pd.DataFrame()
# ["shop_name":"Cats Unlimited","file_type":"json","file_path":"./cats_unlimited.json", "dig_data": ['cats'], "rename_columns": {"img": "image"}}]
for shop in params['shops']:
    temp_data = read_data_from_file(shop['file_path'], shop['file_type'], shop.get('dig_data') )
    temp_df = pd.DataFrame(temp_data)
    if shop.get('rename_columns') != None:
        temp_df = temp_df.rename(columns=shop.get('rename_columns'))

    temp_df['shop'] = 'happy_cats'
    df = pd.concat([df, temp_df], axis=0)
    
if params.get('cat_name') != None:
    df = df[df['name'].str.contains(params['cat_name'], case=False)]

df['price'] = df['price'].astype(int)
df = df.sort_values(by='price', ascending=True)
json_data = df.head(1).to_json(orient='records')
print(json_data)

