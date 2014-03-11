## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'json'

# A helper class that stores the paths to a number of REST resources and
# supports iterating over those resources, downloading them lazily from the
# server.
class Flox::ResultSet

  include Enumerable

  # @return [String]
  attr_reader :path

  # @return [Array<String>]
  attr_reader :ids

  # @param rest_service [RestService]
  #        the service instance used to download the resources.
  # @param path
  #        the path where the resources are stored, relative to the game's root.
  # @param ids [Array<String>]
  #        the identifiers of all the resources that should be enumerated.
  # @param create_resource [Proc]
  #        a block that is called for each resource to convert the raw
  #        result to an arbitrary type (optional)
  def initialize(rest_service, path, ids, &create_resource)
    @service = rest_service
    @path = path.chomp "/"
    @ids = ids
    @create_resource = create_resource || Proc.new {|id, resource| resource}
  end

  # Iterates over the resources provided on initialization, loading them
  # from the server one by one. If you pass a block with one parameter,
  # yields the resource; a block with two parameters yields `id, resource`.
  def each(&block)
    @ids.each do |id|
      case block.arity
      when 0 then yield
      when 1 then yield get_resource(id)
      when 2 then yield id, get_resource(id)
      end
    end
  end

  def length
    @ids.length
  end

  # Pass either the ID (name) of the resource to load,
  # or a Fixnum for the i-th resource.
  def [](index)
    id = index.kind_of?(Fixnum) ? @ids[index] : index.to_s
    get_resource id
  end

  # @return [String] a String representation of the result set.
  def inspect
    "[#{self.class} path:#{@path}, length:#{length}]"
  end

  private

  def get_resource(id)
    @create_resource.call(id, @service.get("#{path}/#{id}"))
  end

  #
  # documentation hints
  #

  # @!attribute length
  #   @return [Fixnum] the total number of objects being enumerated.

end