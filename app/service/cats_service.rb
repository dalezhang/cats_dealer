class CatsService
  SHOPS_CONFIG_PATH = "#{Rails.root}/config/shops.yml"
  
  def self.best_price(name = nil, use_cache = true)
    shops = YAML.load(File.read(SHOPS_CONFIG_PATH))
    params = {cat_name: name, shops: []}
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
    puts "params: #{params.to_json}"
    # [{"shop_name":"Cats Unlimited","file_type":"json","file_path":"./cats_unlimited.json", "dig_data": ['cats'], "rename_columns": {"img": "image"}}]
    result_str = `python lib/python/return_best_price_from_shops.py '#{params.to_json}'`
    JSON.parse(result_str)[0]
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
