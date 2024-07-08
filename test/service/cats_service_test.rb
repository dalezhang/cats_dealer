require 'test_helper'

class CatsServiceTest < ActiveSupport::TestCase
  test "should 1 cat when no name is given" do
    result = CatsService.best_price
    assert result.first.keys.sort, ["image", "location", "name", "price", "shop_name"]
  end

  test "should 1 cat with name include 'curl'" do
    result = CatsService.best_price('curl')
    assert result[0]["name"].downcase.match?(/curl/), true
    assert result.size, 1
  end

  test "should 1 cat when not using the cache" do
    result = CatsService.best_price(nil, false)
    assert result.size, 1
    assert result[0].keys.sort, ["image", "location", "name", "price", "shop_name"]
  end

  test "should return all cats" do
    result = CatsService.best_price(nil, true, 100)
    assert result.size, 21
  end
end
