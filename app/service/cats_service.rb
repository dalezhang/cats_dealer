class CatsService
  SHOPS_CONFIG_PATH = "#{Rails.root}/config/shops.yml"
  
  def self.best_price(name = nil, use_cache = true, max_results_size = 1)
    shops = YAML.load(File.read(SHOPS_CONFIG_PATH))
    params = {cat_name: name, shops: [], max_results_size: max_results_size}
    shops.each do |_, shop|
      path = "#{Rails.root}/tmp/#{shop["file_name"]}"
      if use_cache && FileTest.exist?(path)
        params[:shops] << prepare_params(shop, path)
      else
        begin
          FileDownloader.download(shop["url"], path)
          if FileTest.exist?(path)
            params[:shops] << prepare_params(shop, path)
          end
        rescue StandardError => e
          puts "Error: #{e.message}"
          # TODO: Maybe we should let the client know this shop is not avaliable
        end
      end
    end
	# params =>
    # {"cat_name":null,
	#  "shops":[
	# 	{"shop_name":"Cats Unlimited",
	#    "file_path":"..","file_type":"json",
    #    "dig_data":[],"rename_columns":{}
	#   },
	#   {"shop_name":"Happy Cats",
	#    "file_path":"..",
	#    "file_type":"xml",
    # 	 "dig_data":["cats","cat"],
    #	 "rename_columns":{"title":"name","img":"image","cost":"price"}}
	#   ],
	#   "max_results_size": 1
    #}
    result_str = `python lib/python/return_best_price_from_shops.py '#{params.to_json}'`
	JSON.parse(result_str)
  end

  private

  def self.prepare_params(shop, file_path)
    {
      shop_name: shop['shop_name'],
      file_path: file_path,
      file_type: shop['file_type'],
      dig_data: shop['dig_data'] || [],
      rename_columns: shop['rename_columns'] || {}
    }
  end

end
