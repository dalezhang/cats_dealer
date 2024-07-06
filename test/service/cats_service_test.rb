require 'test_helper'

class CatsServiceTest < ActiveSupport::TestCase
  test "should 1 cat when no name is given" do
    result = CatsService.best_price
    assert result.keys.sort, ["image", "location", "name", "price", "shop_name"]
  end

  test "should 1 cat with name include 'curl'" do
    result = CatsService.best_price('curl')
    assert result["name"].downcase.match?(/curl/), true
  end

  test "should 1 cat when not using the cache" do
    result = CatsService.best_price(nil, false)
    assert result.keys.sort, ["image", "location", "name", "price", "shop_name"]
  end
end
