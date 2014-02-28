## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'json'

# A helper class that stores the paths to a number of REST resources and
# supports iterating over those resources, downloading them lazily from the
# server.
class Flox::ResourceEnumerator

  include Enumerable

  # @param rest_service [RestService]
  #        the service instance used to download the resources.
  # @param paths [Array<String>]
  #        the URLs to the resources that need to be accessed, relative to
  #        the game's root.
  def initialize(rest_service, paths)
    @service = rest_service
    @paths = paths
  end

  # Iterates over the resources provided on intialization, loading them
  # from the server one by one.
  def each
    @paths.each do |path|
      yield @service.get(path)
    end
  end

  def length
    @paths.length
  end

  #
  # documentation hints
  #

  # @!attribute length
  #   @return [Fixnum] the total number of objects being enumerated.

end