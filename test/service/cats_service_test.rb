require 'test_helper'

class CatsServiceTest < ActiveSupport::TestCase
  test "should 10 cats when no name is given" do
    result = CatsService.best_price
    assert result.keys.sort, ["image", "location", "name", "price", "shop_name"]
  end

  test "should 2 cats when name is 'curl'" do
    result = CatsService.best_price('curl')
    assert result["name"].downcase.match?(/curl/), true
  end
end
