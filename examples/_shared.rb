# Nothing to see here... move along.
# Sets up load path for examples and requires some stuff
require 'pp'
require 'pathname'
require_relative './example_log_subscriber'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)
