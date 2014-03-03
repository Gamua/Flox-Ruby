## Author:    Daniel Sperl
## Copyright: Copyright 2014 Gamua
## License:   Simplified BSD

require 'rake/testtask'
require 'fileutils'
require 'yard'

desc 'Run tests'
task :default => :test

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.verbose = true
end

YARD::Rake::YardocTask.new do |t|
  t.options = ["--markup=markdown", "--no-private"]
end

desc 'Remove all files generated by Yard'
task :clobber_yard do
  FileUtils.rm_rf('doc', :verbose=>true)
  FileUtils.rm_rf('.yardoc', :verbose=>true)
end

namespace "bump" do

  desc 'Raises the major version'
  task(:major) { bump_version(:major) }

  desc 'Raises the minor version'
  task(:minor) { bump_version(:patch) }

  desc 'Raises the patch version'
  task(:patch) { bump_version(:patch) }

end

## Helpers

def bump_version(part)

  filename = "lib/flox/version.rb"
  new_version = nil
  all_lines = ""

  File.readlines(filename).each do |line|

    matches = /VERSION\s?=\s?[\"'](\d+\.\d+\.\d+)[\"']/.match(line)
    if matches
      major, minor, patch = *matches[0].split('.').map { |v| v.to_i }

      if    part == :major then major += 1
      elsif part == :minor then minor += 1
      else                      patch += 1
      end

      new_version = "#{major}.#{minor}.#{patch}"
      all_lines += "  VERSION = '#{new_version}'\n"
    else
      all_lines += line
    end
  end

  File.open(filename, 'w') { |f| f.write all_lines } if new_version

end