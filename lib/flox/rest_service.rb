## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'json'
require 'net/http'

# A class that makes it easy to communicate with the Flox server via a REST protocol.
class Flox::RestService

  # @return [String] the unique identifier of the game.
  attr_reader :game_id

  # @return [String] the key that identifies the game.
  attr_reader :game_key

  # @return [String] the URL pointing to the Flox REST API.
  attr_reader :base_url

  def initialize(game_id, game_key, base_url)
    @game_id = game_id
    @game_key = game_key
    @base_url = base_url
    login :guest
  end

  # Makes a `GET` request at the server. The given data-Hash is URI-encoded
  # and added to the path.
  # @return the server response.
  def get(path, data=nil)
    path = full_path(path)
    path += "?" + URI.encode_www_form(data) if data
    request = Net::HTTP::Get.new(path)
    execute(request)
  end

  # Makes a `DELETE` request at the server.
  # @return the server response.
  def delete(path)
    request = Net::HTTP::Delete.new(full_path(path))
    execute(request)
  end

  # Makes a `POST` request at the server. The given data-Hash is transferred
  # in the body of the request.
  # @return the server response.
  def post(path, data=nil)
    request = Net::HTTP::Post.new(full_path(path))
    execute(request, data)
  end

  # Makes a `PUT` request at the server. The given data-Hash is transferred
  # in the body of the request.
  # @return the server response.
  def put(path, data=nil)
    request = Net::HTTP::Put.new(full_path(path))
    execute(request, data)
  end

  # Makes a login on the server with the given authentication data.
  # @return the server response.
  def login(auth_type, auth_id=nil, auth_token=nil)
    auth_data = {
      "authType"  => auth_type,
      "authId"    => auth_id,
      "authToken" => auth_token
    }

    if (auth_type.to_sym == :guest)
      response = auth_data
      auth_data["id"] = String.random_uid
    else
      response = post("authenticate", auth_data)
      auth_data["id"] = response["id"]
    end

    @authentication = auth_data
    response
  end

  # @return [String] provides a simple string representation of the service.
  def inspect
    "[RestService game_id: #{game_id}, base_url: #{base_url}]"
  end

  private

  def execute(request, data=nil)
    flox_header = {
      "sdk" => { "type" => "ruby", "version" => Flox::VERSION },
      "gameKey" => @game_key,
      "dispatchTime" => Time.now.utc.to_xs_datetime,
      "player" => @authentication
    }

    request["Content-Type"] = "application/json"
    request["X-Flox"] = flox_header.to_json
    request.body = data.to_json if data

    uri = URI.parse(@base_url)
    http = Net::HTTP::new(uri.host, uri.port)

    if uri.scheme == "https"  # enable SSL/TLS
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end

    http.start do |session|
      response = session.request(request)
      if (response.is_a? Net::HTTPSuccess)
        return JSON.parse(response.body || '{}')
      else
        message = begin
          JSON.parse(response.body)['message']
        rescue
          response.body
        end
        raise Flox::Error, message
      end
    end
  end

  def full_path(path)
    "/api/games/#{@game_id}/#{path}"
  end

end
