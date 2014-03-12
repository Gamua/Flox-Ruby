## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

# An Entity that contains information about a Flox Player.
# Normally, you don't create instances of `Player` yourself. There's always
# a player logged in you can access with
#
#     flox.current_player # => Flox::Player
#
# To log in as a different player, you'll probably want to use a `key`-login.
# When you use the Flox Gem as a maintenance tool, create a "Hero" in the
# online interface and use its key to login. That way, you have access to
# all entities, regardless of their `public_access` values.
#
#     flox.login_with_key 'hero-key' # => Flox::Player
#
# The Player class itself is just an entity that adds an `auth_type`
# property for your convenience.
class Flox::Player < Flox::Entity

  # Creates a player with a certain ID and data. The `type` of a player
  # is always `.player` in Flox.
  def initialize(id=nil, data=nil)
    data ||= {}
    data[:authType] ||= "guest"
    data[:publicAccess] ||= "r"
    super(".player", id, data)
    self.owner_id ||= self.id
  end

  def auth_type
    self[:authType].to_sym
  end

  #
  # documentation hints
  #

  # @!attribute auth_type
  #   @return [String] the type of authentication the player used to log in.

end
