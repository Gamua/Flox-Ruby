## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'flox'
require 'test/unit'
require 'mocha/test_unit'

class FloxTest < Test::Unit::TestCase

  GAME_ID  = "game_id"
  GAME_KEY = "game_key"
  BASE_URL = "http://url.com"

  attr_reader :flox

  def setup
    @flox = Flox.new(GAME_ID, GAME_KEY, BASE_URL)
  end

  def test_init
    assert_equal(GAME_ID, flox.game_id)
    assert_equal(GAME_KEY, flox.game_key)
    assert_equal(BASE_URL, flox.base_url)

    assert_kind_of(Flox::Player, flox.current_player)
    assert_equal(:guest, flox.current_player.auth_type)
  end

  def test_post_score
    flox.service.expects(:post).once
    flox.post_score('leaderboard_id', 123, 'player_name')
  end

  def test_load_scores
    leaderboard_id = "dummy"
    path = "leaderboards/#{leaderboard_id}"
    raw_score = {
      'value' => 20,
      'playerName' => 'hugo',
      'playerId' => '123',
      'country' => 'at',
      'createdAt' => '2014-02-24T20:15:00.123Z'
    }

    # using time scope (t)
    flox.service.expects(:get).once.with(path, has_key('t')).returns([])
    scores = flox.load_scores(leaderboard_id, :today)
    assert_kind_of(Array, scores)
    assert_equal(0, scores.length)

    # using player scope (p)
    flox.service.expects(:get).once.with(path, has_key('p')).returns([raw_score])
    scores = flox.load_scores(leaderboard_id, %w(1, 2, 3))
    assert_kind_of(Array, scores)
    assert_equal(1, scores.length)

    highscore = scores.first
    assert_kind_of(Flox::Score, highscore)
    assert_equal(raw_score['value'], highscore.value)
    assert_equal(raw_score['playerName'], highscore.player_name)
    assert_equal(raw_score['playerId'], highscore.player_id)
    assert_equal(raw_score['country'], highscore.country)
    assert_equal(raw_score['createdAt'], highscore.created_at.to_xs_datetime)
  end

  def test_login_with_key
    key = "key"
    result = { 'id' => '123', 'entity' => { 'authType' => 'key' } }
    flox.service.expects(:login).with(:key, key, nil).once.returns(result)
    player = flox.login_with_key(key)
    assert_not_nil(player)
    assert_equal(:key, player.auth_type)
    assert_equal(player, flox.current_player)
  end

  def test_login_guest
    player = flox.login_guest
    assert_not_nil(player)
    assert_equal(:guest, player.auth_type)
    assert_equal(player, flox.current_player)
  end

  def test_load_entity
    type = "type"
    id   = "id"
    path = "entities/#{type}/#{id}"
    data = { "name" => "Jean-Luc" }

    flox.service.expects(:get).with(path).once.returns(data)
    entity = flox.load_entity(type, id)

    assert_kind_of(Flox::Entity, entity)
    assert_equal(id, entity.id)
    assert_equal(type, entity.type)
    assert_equal(path, entity.path)
    assert_equal(data["name"], entity["name"])
  end

  def test_load_player
    id = "id"
    data = { "name" => "Jean-Luc" }
    flox.service.expects(:get).once.returns(data)
    player = flox.load_player(id)
    assert_kind_of(Flox::Player, player)
    assert_equal(data["name"], player["name"])
    assert_equal(id, player.id)
    assert_equal('.player', player.type)
  end

  def test_save_entity
    data   = { "name" => "Jean-Luc" }
    entity = Flox::Entity.new("type", "id", data)
    path   = "entities/#{entity.type}/#{entity.id}"
    result = { "createdAt" => "2014-01-01T12:00:00.000Z",
               "updatedAt" => "2014-02-01T12:00:00.000Z" }

    flox.service.expects(:put).with(path, entity).once.returns(result)
    flox.save_entity(entity)

    assert_equal(result["createdAt"], entity.created_at.to_xs_datetime)
    assert_equal(result["updatedAt"], entity.updated_at.to_xs_datetime)
  end

  def test_delete_entity
    entity = Flox::Entity.new("type", "id")
    path   = "entities/#{entity.type}/#{entity.id}"
    flox.service.expects(:delete).with(path)
    flox.delete_entity(entity)
  end

  def test_find_logs
    log_ids = %w{ 0 1 2 }
    result = { 'ids' => log_ids, 'cursor' => nil }
    flox.service.expects(:get).at_most_once.returns(result)
    logs = flox.load_logs(':warning', 50)
    assert_kind_of(Flox::ResourceEnumerator, logs)
    assert_equal(log_ids.length, logs.length)
    flox.service.expects(:get).times(log_ids.length).returns({})
    logs.each { |log| assert_kind_of(Hash, log) }
  end

  def test_find_log_ids
    log_ids   = %w{ 0 1 2 3 4 5 6 7 8 9 }
    log_ids_a = log_ids.slice 0, 5
    log_ids_b = log_ids.slice 5, 5
    result_a = { 'ids' => log_ids_a, 'cursor' => 'a' }
    result_b = { 'ids' => log_ids_b, 'cursor' => nil }

    # without limit
    flox.service.expects(:get).twice.returns(result_a, result_b)
    out_log_ids = flox.load_log_ids
    assert_equal(log_ids.length, out_log_ids.length)

    # with limit
    limit = 7
    result_b['ids'] = %w{ 5 6 }
    flox.service.expects(:get).twice.returns(result_a, result_b)
    out_log_ids = flox.load_log_ids(nil, limit)
    assert_equal(limit, out_log_ids.length)
  end

end
