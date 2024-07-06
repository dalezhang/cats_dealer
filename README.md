Test case 1: Cats Dealer
==================

You are going to create a simple service that allows finding the best cat with the best price for customer.

There are cat shops that have pricelists accessible via REST API. What your service will do is just get prices from each shop, compare them and suggest the best deal for a customer!

We created 2 fake test shops for you.
1. "Cats Unlimited" API (JSON response) - [https://nh7b1g9g23.execute-api.us-west-2.amazonaws.com/dev/cats/json](https://nh7b1g9g23.execute-api.us-west-2.amazonaws.com/dev/cats/json)
2. "Happy Cats" API (XML response) - [https://nh7b1g9g23.execute-api.us-west-2.amazonaws.com/dev/cats/xml](https://nh7b1g9g23.execute-api.us-west-2.amazonaws.com/dev/cats/xml)


### The task is the following:
1. The script must accept part of the product name (e.g. `curl`) as input.
2. At the output it returns the full name of the product, its price and the store name.
3. Implement "XML" and "JSON" integration, and improve business logic to find the best deal amongst two shops.
4. Auto tests welcome


#### Things to watch out for:
* Right now our product supports only two cat shops. However, that can change in a future.
* As you know, 3rd-party integrations often behave unpredictably. Let's make sure that our product can handle errors from these services.
* In the response, some APIs can return really a lot of data. How would you solve this problem?


# Solution

> Right now our product supports only two cat shops. However, that can change in a future.

Add shops config at `config/shops.yml`

Example:

```yml
happy_cats:
  shop_name: "Happy Cats"
  file_type: "xml"
  file_name: "happy_cats.xml"
  url: "https://nh7b1g9g23.execute-api.us-west-2.amazonaws.com/dev/cats/xml"
  rename_columns: {"title": "name", "img": "image", "cost": "price"} # The output name should be ["image", "location", "name", "price", "shop_name"]. If the data source use a different name, We should rename them. Especially the "price" and the "name", We use price to order and use name to find cats.
  dig_data: ['cats','cat'] # If the url return a nested data. For example `{"cats": {"cat": [{"name": "Curl", "price": "10"}]}}`. We should dig it by this setting.

```

> As you know, 3rd-party integrations often behave unpredictably. Let's make sure that our product can handle errors from these services.

Currently, I have rescue the error. And store the response data in `tmp` folder.
- If it is the first time call this service. Those unavaliable url will be skipped.
- If it is not the first time. You can use the store response in `tmp` folder. Or you can choice not using the cache by `CatsService.best_price(nil, false)`. The second param is if the service should use cache files or not. Use `true` by default.
    - If one url is not avaliable before. If will not have a cache file in `tmp` folder. We will try to call this url again.

> In the response, some APIs can return really a lot of data. How would you solve this problem?

When we have a lot of data. One choice is store them in a database. And searching and sorting by database.

However in some situation this is not a good idea. For example the cats imformation in each shop often changes. Some cats are not avaliable anymore. It's not a good idea to update the data in database each time we do the request.

So I used `pandas` in python script to do the job. `pandas` is good at dealing with big data. Especially combining data and sorting. With much lower memory cost then Ruby. I save the the response body of shop urls in `tmp` folder. Then use python script to read these file and search the best price cat we need.



### How to use

```sh
pip install xmltodict
pip install pandas
bundle install
```


```ruby
use_cache = false
result = CatsService.best_price('curl', use_cache)
```

### How to test

```sh
rails test test/service/cats_service_test.rb
```
