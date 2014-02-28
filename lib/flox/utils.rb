## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'securerandom'

# Flox-extensions to the standard Time class.
class Time

  # @return [String] an XS-DateTime representation of the string, like this:
  #   `2014-02-20T20:15:00.123Z`
  def to_xs_datetime
    strftime("%Y-%m-%dT%H:%M:%S.%LZ")
  end

end

# Flox-extensions to the standard Time class.
class String

  # @return [String] creates a random alphanumeric string with a given length.
  def self.random_uid(length=16)
    SecureRandom.base64(length * 2).gsub(/[\+\/]/, '').slice(0, length)
  end

  # @return [String] converts a `camelCase` string to its `under_score` equivalent.
  def to_underscore
    gsub(/(.)([A-Z])/,'\1_\2').downcase
  end

  # @return [String] converts a string that separates its words with space,
  #   underscore or dash into its `camelCase` equivalent.
  def to_camelcase
    words = downcase.split(/[_\-\s]/)
    words.shift + words.map(&:capitalize).join
  end

end