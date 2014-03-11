## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

# The Query class allows you to retrieve entities from the server by narrowing
# down the results with certain constraints. The system works similar to SQL
# "select" statements.
#
# Before you can make a query, you have to create indices that match the query.
# You can do that in the Flox online interface. An index has to contain all the
# properties that are referenced in the constraints.
#
# Here is an example of how you can execute a Query with Flox. This query
# requires an index containing both "level" and "score" properties.
#
#     query = Query.new(:Player)
#     query.where("level == ? AND score > ?", "tutorial", 500)
#     query.limit = 1
#     results = flox.find_entities(query)
#
# Alternatively, you can execute the query in one single line:
#
#     results = flox.find_entities(:Player, "score > ?", 500)
#     puts "Found #{results.length} players"
#
class Flox::Query

  # @return [String] the constraints that will be used as WHERE-clause.
  #   It is recommended to use the {#where} method to construct them.
  attr_accessor :constraints

  # @return [Fixnum] the offset of the results returned by the query.
  attr_accessor :offset

  # @return [Fixnum] the maximum number of returned entities.
  attr_accessor :limit

  # @return [String] the entity type that is searched.
  attr_reader :type

  # Create a new query that will search within the given Entity type.
  # Optionally, pass the constraints in the same way as in the {#where} method.
  # @param entity_type [String, Symbol, Class] the type of the entity
  def initialize(entity_type, constraints=nil, *args)
    if entity_type == Flox::Player || entity_type.to_s == "Player"
      entity_type = '.player'
    end

    @type = entity_type
    @offset = 0
    @limit = 50
    where(constraints, *args) if constraints
  end

  # You can narrow down the results of the query with an SQL like where-clause.
  # The constraints string supports the following comparison operators:
  # `==, >, >=, <, <=, !=`. You can combine constraints using `AND` and `OR`;
  # construct logical groups with round brackets.
  #
  # To simplify creation of the constraints string, you can use questions
  # marks as placeholders. They will be replaced one by one with the additional
  # parameters you pass to the method, while making sure their format is correct
  # (e.g. it surrounds Strings with quotations marks). Here is an example:
  #
  #     query.where("name == ? AND score > ?", "thomas", 500);
  #     # -> name == "thomas" AND score > 500
  #
  # Use the 'IN'-operator to check for inclusion within a list of possible values:
  #
  #     query.where("name IN ?", ["alfa", "bravo", "charlie"]);
  #     # -> name IN ["alfa", "bravo", "charlie"]
  #
  # Note that subsequent calls to this method will replace preceding constraints.
  # @return [Flox::ResultSet<Flox::Entity>]
  def where(constraints, *args)
    @constraints = constraints.gsub(/\?/) do
      raise ArgumentError, "incorrect placeholder count" unless args.length > 0
      arg = args.shift
      arg = arg.to_xs_datetime if arg.kind_of?(Time)
      arg.to_json
    end
  end

end