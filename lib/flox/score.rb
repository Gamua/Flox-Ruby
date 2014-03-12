## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

# Provides information about the value and origin of one posted score entry.
class Flox::Score

  # @return [String] the ID of the player who posted the score.
  #   Note that this could be a guest player unknown to the server.
  attr_reader :player_id

  # @return [String] the name of the player who posted the score.
  attr_reader :player_name

  # @return [Fixnum] the actual score.
  attr_reader :value

  # @return [String] the country from which the score originated, in a
  #   two-letter country code.
  attr_reader :country

  # @return [Time] the date at which the score was posted.
  attr_reader :created_at

  # @param data [Hash] the contents of the score as given by the Flox server.
  def initialize(data)
    @player_id = data[:playerId].to_s
    @player_name = data[:playerName].to_s
    @value = data[:value].to_i
    @country = data[:country].to_s
    @created_at = Time.parse(data[:createdAt].to_s)
  end

end
