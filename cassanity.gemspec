# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cassanity/version'

Gem::Specification.new do |gem|
  gem.name          = "cassanity"
  gem.version       = Cassanity::VERSION
  gem.authors       = ["John Nunemaker"]
  gem.email         = ["nunemaker@gmail.com"]
  gem.description   = %q{Layer of goodness on top of cassandra-cql so you do not have to write CQL strings all over the place.}
  gem.summary       = %q{Layer of goodness on top of cassandra-cql so you do not have to write CQL strings all over the place.}
  gem.homepage      = "https://github.com/jnunemaker/cassanity/"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'cassandra-cql', '~> 1.1.3'
end
