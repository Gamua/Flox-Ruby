## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'flox'
require 'test/unit'
require 'mocha/setup'

class FloxTest < Test::Unit::TestCase

  def test_constraints
    time_xs = "2014-03-10T14:00:00.124Z"
    time = Time.parse(time_xs)
    query = Flox::Query.new("Type")
    query.where "count >= ? AND (name == ? OR date <= ?)", 10, "hugo", time
    assert_equal("count >= 10 AND (name == \"hugo\" OR date <= \"#{time_xs}\")",
      query.constraints, "wrong placeholder replacement")
  end

  def test_constraints_with_array
    query = Flox::Query.new("Type")
    query.where "name IN ?", %w{ alpha bravo charlie }
    assert_equal('name IN ["alpha","bravo","charlie"]', query.constraints)
  end

  def test_offset
    query = Flox::Query.new("Type")
    query.offset = 15
    assert_equal(15, query.offset)
  end

  def test_limit
    query = Flox::Query.new("Type")
    query.limit = 5
    assert_equal(5, query.limit)
  end

  def test_order_by
    query = Flox::Query.new("Type")
    query.order_by = "updated_at DESC"
    assert_equal("updated_at DESC", query.order_by)
  end

  def test_constraints_checks_argument_count
    query = Flox::Query.new("Type")
    assert_raise ArgumentError do
      query.where "a == ? AND b == ?", 10
    end
  end

  def test_run_query
    flox = Flox.new("game_id", "game_key")
    query = Flox::Query.new("Type", "score > ?", 100)
    flox.service.expects(:request).times(3).returns([{id: 1}, {id: 2}])
      .then.returns({score: 101}, {score: 102})
    results = flox.find_entities query
    assert_equal 2, results.length

    result_0 = results[0]
    assert_kind_of(Flox::Entity, result_0)
    assert_equal(101, result_0[:score])

    result_1 = results[1]
    assert_kind_of(Flox::Entity, result_1)
    assert_equal(102, result_1[:score])
  end

  def test_run_query_direct
    flox = Flox.new("game_id", "game_key")
    flox.service.expects(:request).times(3).returns([{id: 1}, {id: 2}])
      .then.returns({}, {})
    results = flox.find_entities "Type", "score > ?", 100
    assert_equal 2, results.length
  end

end