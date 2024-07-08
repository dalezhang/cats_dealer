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

# This method can convert value to category type. If the value repeat many times. Convert to catetory will save a lot memory.
def convert_repeat_values_to_category(df, convert_columns):
	for col in convert_columns:
		df[col] = df[col].astype('category')


df = pd.DataFrame()

for shop in params['shops']:
    temp_data = read_data_from_file(shop['file_path'], shop['file_type'], shop.get('dig_data') )
    temp_df = pd.DataFrame(temp_data)
    if shop.get('rename_columns') != None:
        temp_df = temp_df.rename(columns=shop.get('rename_columns'))

    temp_df['shop'] = shop['shop_name']
    df = pd.concat([df, temp_df], axis=0)
    convert_repeat_values_to_category(df, ['name', 'shop', 'location'])
    
if params.get('cat_name') != None:
    df = df[df['name'].str.contains(params['cat_name'], case=False)]

df['price'] = df['price'].astype(int)
df = df.sort_values(by='price', ascending=True)
json_data = df.head(1).to_json(orient='records')
print(json_data)

