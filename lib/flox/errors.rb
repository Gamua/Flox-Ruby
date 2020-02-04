## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

# The main Error class for Flox errors
class Flox::Error < StandardError; end

# Raised when the REST service encounters an error
# (e.g. the server returns a HTTP code >= 400).
class Flox::ServiceError < Flox::Error

  # @return [Net::HTTPResponse] the complete server response
  attr_reader :response

  # @param response [Net::HTTPResponse] the complete server response
  def initialize(response)
    @response = response
  end

end