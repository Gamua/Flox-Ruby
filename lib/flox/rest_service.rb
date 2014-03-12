## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'json'
require 'zlib'
require 'base64'
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
    request(:get, path, data)
  end

  # Makes a `DELETE` request at the server.
  # @return the server response.
  def delete(path)
    request(:delete, path)
  end

  # Makes a `POST` request at the server. The given data-Hash is transferred
  # in the body of the request.
  # @return the server response.
  def post(path, data=nil)
    request(:post, path, data)
  end

  # Makes a `PUT` request at the server. The given data-Hash is transferred
  # in the body of the request.
  # @return the server response.
  def put(path, data=nil)
    request(:put, path, data)
  end

  # Makes a request on the Flox server. When called without a block, the
  # method will raise a {Flox::ServiceError} if the server returns an HTTP
  # error code; when called with a block, it will always succeed.
  #
  # @yield [body, response] The decoded body and the raw http response
  # @param method [Symbol] one of `:get, :delete, :put, :post`
  # @param path [String] the path relative to the game, e.g. "entities/product"
  # @param data [Hash] the body of the request.
  # @return the body of the server response
  def request(method, path, data=nil)
    request_class =
      case method
      when :get
        if data
          path += "?" + URI.encode_www_form(data)
          data = nil
        end
        Net::HTTP::Get
      when :delete then Net::HTTP::Delete
      when :post   then Net::HTTP::Post
      when :put    then Net::HTTP::Put
      end

    flox_header = {
      :sdk => { :type => "ruby", :version => Flox::VERSION },
      :gameKey => @game_key,
      :dispatchTime => Time.now.utc.to_xs_datetime,
      :bodyCompression => "zlib",
      :player => @authentication
    }

    request = request_class.new(full_path(path))
    request["Content-Type"] = "application/json"
    request["X-Flox"] = flox_header.to_json
    request.body = encode(data.to_json) if data

    uri = URI.parse(@base_url)
    http = Net::HTTP::new(uri.host, uri.port)

    if uri.scheme == "https"  # enable SSL/TLS
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.use_ssl = true
    end

    http.start do |session|
      response = session.request(request)
      body = body_from_response response

      if block_given?
        # if a block was passed to the method, no error is thrown
        yield  body, response
        return body
      else
        # without a block, we raise an error if the request was not a success
        if (response.is_a? Net::HTTPSuccess)
          return body
        else
          raise Flox::ServiceError.new(response), (body[:message] rescue body)
        end
      end
    end
  end

  # Makes a login on the server with the given authentication data.
  # @return the server response.
  def login(auth_type, auth_id=nil, auth_token=nil)
    auth_data = {
      :authType  => auth_type,
      :authId    => auth_id,
      :authToken => auth_token
    }

    if (auth_type.to_sym == :guest)
      response = auth_data
      auth_data[:id] = String.random_uid
    else
      if @authentication[:authType] == :guest
        auth_data[:id] = @authentication[:id]
      end
      response = post("authenticate", auth_data)
      auth_data[:id] = response[:id]
    end

    @authentication = auth_data
    response
  end

  # @return [String] provides a simple string representation of the service.
  def inspect
    "[RestService game_id: #{game_id}, base_url: #{base_url}]"
  end

  private

  def decode(string)
    return nil if string.nil? or string.empty?
    Zlib::Inflate.inflate(Base64.decode64(string))
  end

  def encode(string)
    return nil if string.nil?
    Base64.encode64(Zlib::Deflate.deflate(string))
  end

  def body_from_response(response)
    body = response.body

    begin
      body = decode(response.body) if response['x-content-encoding'] == 'zlib'
      JSON.parse(body || '{}', {symbolize_names: true})
    rescue
      html_matches = /\<h1\>(.*)\<\/h1\>/.match(body)
      { message: html_matches ? html_matches[1] : body }
    end
  end

  def full_path(path)
    "/api/games/#{@game_id}/#{path}"
  end

end
