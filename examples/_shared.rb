# Nothing to see here... move along.
# Sets up load path for examples and requires some stuff
require 'pp'
require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'logger'
require 'cassanity/instrumentation/log_subscriber'

Cassanity::Instrumentation::LogSubscriber.logger = Logger.new(STDOUT, Logger::DEBUG)
