## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require File.join(File.dirname(__FILE__), "lib", "flox", "version")

Gem::Specification.new do |s|
  s.name        = 'flox'
  s.version     = Flox::VERSION
  s.date        = '2014-02-21'
  s.author      = 'Daniel Sperl'
  s.email       = 'daniel@gamua.com'
  s.files       = Dir.glob('{bin,test,lib}/**/*')
  s.homepage    = 'https://www.flox.cc'
  s.license     = 'Simplified BSD'
  s.summary     = 'Ruby SDK for the flox.cc game backend'
  s.description = <<-EOF
Flox is the no-fuzz backend for game developers. The Ruby SDK allows direct
interaction with the Flox servers, e.g. to download log files or update
specific entities. It can be used from other Ruby scripts or directly with
its bundled command-line utility.
  EOF

  s.add_runtime_dependency 'json'
  s.add_development_dependency 'mocha', '~> 1.0'
  s.add_development_dependency 'yard',  '~> 0.8'
end
