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
  s.files       = ["README.md", "LICENSE.md", ".yardopts"] + Dir.glob('{bin,test,lib}/**/*')
  s.executables = 'flox'
  s.homepage    = 'https://www.flox.cc'
  s.license     = 'BSD-2-Clause'
  s.summary     = 'Ruby SDK for the flox.cc game backend'
  s.description = <<-EOF
Flox is the no-fuzz backend for game developers. The Ruby SDK allows direct
interaction with the Flox servers, e.g. to download log files or update
specific entities. It can be used from other Ruby scripts or directly with
its bundled command-line utility.
  EOF

  s.add_runtime_dependency 'json', '~> 2.3.0'
  s.add_runtime_dependency 'slop', '~> 3.4.7'
  s.add_development_dependency 'test-unit', '~> 3.3.5'
  s.add_development_dependency 'mocha', '~> 1.0'
  s.add_development_dependency 'yard',  '~> 0.9.11'
  s.add_development_dependency 'rake', '~> 13.0'
end
