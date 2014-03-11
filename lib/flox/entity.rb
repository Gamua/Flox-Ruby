## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'time'

# The base class of all objects that can be stored persistently on the Flox
# server.
#
# The class extends `Hash`. Thus, all properties of the Entity can be accessed
# as keys of the Entity instance.
#
#     entity[:name] = 'Donald Duck'
#
# For convenience, the standard entity properties (e.g. `created_at` and
# `updated_at`)can be accessed via Ruby attributes.
#
#     entity.public_access = 'rw'
#
# To load and save an entity, use the respective methods on the Flox class.
#
#     my_entity = flox.load_entity(:SaveGame, '12345') # => Flox::Entity
#     flox.save_entity(my_entity)
#
class Flox::Entity < Hash

  # @return [String] the primary identifier of the entity.
  attr_accessor :id

  # @return [String] the type of the entity. Types group entities together on the server.
  attr_reader :type

  # @param type [String] Typically the class name of the entity (as used in the other SDKs).
  # @param id [String] The unique identifier of the entity.
  # @param data [Hash] The initial contents of the entity.
  def initialize(type, id=nil, data=nil)
    @type = type
    @id = id ? id : String.random_uid
    self[:createdAt] = self[:updatedAt] = Time.now.utc.to_xs_datetime
    self[:publicAccess] = ''
    if (data)
      data_sym = Hash[data.map{|k, v| [k.to_sym, v]}]
      self.merge!(data_sym)
    end
  end

  def created_at
    Time.parse self[:createdAt]
  end

  def updated_at
    Time.parse self[:updatedAt]
  end

  def public_access
    self[:publicAccess]
  end

  def public_access=(access)
    self[:publicAccess] = access.to_s
  end

  def owner_id
    self[:ownerId]
  end

  def owner_id=(value)
    self[:ownerId] = value.to_s
  end

  def path
    "entities/#{@type}/#{@id}"
  end

  # @return [String] provides a simple string representation of the Entity.
  def inspect
    description = "[#{self.class} #{@id} (#{@type})\n"
    each_pair do |key, value|
      description += "    #{key}: #{value}\n"
    end
    description += "]"
  end

  # Accesses a property of the entity; both symbols and strings work.
  def [](key)
    super(key.to_sym)
  end

  # (see #[])
  def []=(key, value)
    super(key.to_sym, value)
  end

  #
  # documentation hints
  #

  # @!attribute owner_id
  #   @return [String] the player ID of the owner of the entity
  #     (referencing a Player entitity).

  # @!attribute created_at
  #   @return [Time] the time the entity was created.

  # @!attribute updated_at
  #   @return [Time] the time the entity was last changed on the server.

  # @!attribute public_access
  #   @return [String] the access rights of all players except the owner
  #     (the owner always has unlimited access). Possible values: '', 'r', 'rw'

  # @!attribute [r] path
  #   @return [String] the path to the REST-resource of the entity, relative
  #     to the game's root.

end
