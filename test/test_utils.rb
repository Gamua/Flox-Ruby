## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'flox'
require 'test/unit'

class EntityTest < Test::Unit::TestCase

  def test_random_uid
    length = 16
    uid = String.random_uid(length)
    assert_equal(length, uid.length)
    assert_match(/^[a-zA-Z0-9]+$/, uid)
  end

  def test_xs_datetime
    time_xs = "2014-02-20T11:00:00.124Z"
    time = Time.parse(time_xs)
    assert_equal(time_xs, time.to_xs_datetime)
  end

  def test_to_camelcase
    assert_equal("homeSweetHome", "home_sweet_home".to_camelcase)
    assert_equal("homeSweetHome", "hOME-sWEET-hOME".to_camelcase)
    assert_equal("homeSweetHome", "Home Sweet Home".to_camelcase)
  end

  def test_to_underscore
    assert_equal("home_sweet_home", "HomeSweetHome".to_underscore)
    assert_equal("home_sweet_home", "homeSweetHome".to_underscore)
  end

end