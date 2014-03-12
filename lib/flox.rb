## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

# The main class used to interact with the Flox cloud service. Create an
# instance of Flox using the game ID and key acquired from the web interface,
# then login with a "Hero" key. That way, you will be able to access the data
# of all players.
class Flox

  # The URL where the Flox servers are found.
  DEFAULT_URL = "https://www.flox.cc"

  # @private
  attr_reader :service

  # @return [Flox::Player] The player that is currently logged in.
  attr_reader :current_player

  # Creates a new instance with a certain game ID and key. Per default, a guest
  # player will be logged in. You probably need to call 'login_with_key' with a
  # Hero-key to access your data.
  def initialize(game_id, game_key, base_url=Flox::DEFAULT_URL)
    @service = RestService.new(game_id, game_key, base_url)
    self.login_guest
  end

  # Makes a key-login on the server. It is recommended to create a 'hero'
  # player in the web interface and use that for the login. After the login,
  # `current_player` will point to this player.
  # @return [Flox::Player]
  def login_with_key(key)
    login(:key, key)
  end

  # Creates a new guest player and logs it in. After the login,
  # `current_player` will point to this player.
  # @return [Flox::Player]
  def login_guest()
    login(:guest)
  end

  # Logging out the current player automatically logs in a new guest.
  alias_method :logout, :login_guest

  # @private
  def login(auth_type, auth_id=nil, auth_token=nil)
      data = service.login(auth_type, auth_id, auth_token)
      @current_player = Player.new(data['id'], data['entity'])
  end

  # Loads an entity with a certain type and id from the server.
  # Normally, the type is the class name you used for the entity in your game.
  # @return [Flox::Entity]
  def load_entity(type, id)
    path = entity_path(type, id)
    data = service.get(path)
    create_entity(type, id, data)
  end

  # Loads an entity with type '.player'.
  # @return [Flox::Player]
  def load_player(id)
    load_entity('.player', id)
  end

  # Stores an entity on the server.
  # @return [Flox::Entity]
  def save_entity(entity)
    result = service.put(entity.path, entity)
    entity['updatedAt'] = result['updatedAt']
    entity['createdAt'] = result['createdAt']
    entity
  end

  # Deletes the given entity from the database.
  # @overload delete_entity(entity)
  #   @param [Flox:Entity] entity the entity to delete
  # @overload delete_entity(type, id)
  #   @param [String] type the type of the entity
  #   @param [String] id the id of the entity
  def delete_entity(*entity)
    if entity.length > 1
      type, id = entity[0], entity[1]
    else
      type, id = entity[0].type, entity[0].id
    end
    service.delete(entity_path(type, id))
    nil
  end

  # Posts a score to a certain leaderboard. Beware that only the top score of
  # a player will appear on the leaderboard.
  def post_score(leaderboard_id, score, player_name)
    path = leaderboard_path(leaderboard_id)
    data = { playerName: player_name, value: score }
    service.post(path, data)
  end

  # Loads all scores of a leaderboard, sorted by rank. 'scope' can either be
  # one of the symbols +:today, :this_week, :all_time+ or an array of player IDs.
  # @return [Array<Flox::Score>]
  def load_scores(leaderboard_id, scope)
    path = leaderboard_path(leaderboard_id)
    args = {}

    if scope.is_a?(Array)
      args['p'] = scope
    else
      args['t'] = scope.to_s.to_camelcase
    end

    raw_scores = service.get(path, args)
    raw_scores.collect { |raw_score| Score.new(raw_score) }
  end

  # Loads a JSON object from the given path. This works with any resource
  # e.g. entities, logs, etc.
  # @return [Hash]
  def load_resource(path, args=nil)
    service.get(path, args)
  end

  # Loads a bulk of resources from a certain path, optionally feeding them
  # through a block.
  # @yield [id, resource] called on every resource; the return-value is feeded
  #                       into the result array.
  # @return [Array]
  def load_resources(path, ids)
    ids.map do |id|
      resource = load_resource "#{path}/#{id}"
      resource = yield id, resource if block_given?
      resource
    end
  end

  # Loads a log with a certain ID. A log is a Hash instance.
  # @return [Hash]
  def load_log(log_id)
    service.get log_path(log_id)
  end

  # Finds logs defined by a certain query.
  # Here are some sample queries:
  #
  # * `day:2014-02-20` → all logs of a certain day
  # * `severity:warning` → all logs of type warning & error
  # * `severity:error` → all logs of type error
  # * `day:2014-02-20 severity:error` → all error logs from February 20th.
  #
  # @return [Array<Hash>]
  def find_logs(query=nil, limit=nil)
    log_ids = find_log_ids(query, limit)
    load_resources('logs', log_ids)
  end

  # Finds just the IDs of the logs, defined by a certain query.
  # @see {#find_logs}
  # @return [Array<String>]
  def find_log_ids(query=nil, limit=nil)
    log_ids = []
    cursor = nil
    begin
      args = {}
      args['q'] = query  if query
      args['l'] = limit  if limit
      args['c'] = cursor if cursor

      result = service.get "logs", args
      cursor = result["cursor"]
      log_ids += result["ids"]
      limit -= log_ids.length if limit
    end while !cursor.nil? and (limit.nil? or limit > 0)
    log_ids
  end

  # Executes a query over Entities, using a simple SQL-like syntax.
  # @see Flox::Query
  #
  # @overload find_entities(query)
  #   @param query [Flox::Query] the query to execute
  # @overload find_entities(entity_type, constraints=nil, *args)
  #   @param type [String, Symbol, Class] the type of the entity
  #   @param query [String] the query string with optional '?' placeholders
  def find_entities(*query)
    query = create_query(*query)
    ids = find_entity_ids(query)
    load_resources "entities/#{query.type}", ids do |id, data|
      create_entity(query.type, id, data)
    end
  end

  # Executes a query over Entities, using a simple SQL-like syntax.
  # @return [Array<String>]
  # @see #find_entities
  # @see Flox::Query
  def find_entity_ids(*query)
    query = create_query(*query)
    path = "entities/#{query.type}"
    data = { where: query.constraints, offset: query.offset, limit: query.limit }
    service.post(path, data).map {|e| e[:id]}
  end

  # Loads the status of the Flox service.
  # @return [Hash] with the keys 'status' and 'version'.
  def status
    service.get("")
  end

  # The ID of the game you are accessing.
  # @return [String]
  def game_id
    service.game_id
  end

  # The key of the game you are accessing.
  # @return [String]
  def game_key
    service.game_key
  end

  # The base URL of the Flox service.
  # @return [String]
  def base_url
    service.base_url
  end

  # @return [String] a string representation of the object.
  def inspect
    "[Flox game_id: '#{game_id}', base_url: '#{base_url}']"
  end

  private

  def entity_path(type, id)
    "entities/#{type}/#{id}"
  end

  def leaderboard_path(leaderboard_id)
    "leaderboards/#{leaderboard_id}"
  end

  def log_path(log_id)
    "logs/#{log_id}"
  end

  def create_entity(type, id, data)
    if (type == '.player' or type == Flox::Player)
      Player.new(id, data)
    else
      Entity.new(type, id, data)
    end
  end

  def create_query(*query)
    if query[0].kind_of? Flox::Query then query[0]
    else Flox::Query.new(query[0], query[1], *query[2..-1])
    end
  end

end

require 'flox/rest_service'
require 'flox/version'
require 'flox/errors'
require 'flox/entity'
require 'flox/player'
require 'flox/score'
require 'flox/query'
require 'flox/utils'
