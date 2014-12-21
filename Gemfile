source 'https://rubygems.org'
gemspec

gem 'dotenv'
gem 'rake'
gem 'rspec', '~> 2.8'
gem 'activesupport', '~>3.2', :require => false
gem 'metriks', :require => false
gem 'statsd-ruby', :require => false

group(:guard) do
  gem 'guard'
  gem 'guard-rspec'
  gem 'guard-bundler'
  gem 'rb-fsevent'
end

group(:development) do
  gem 'pry-byebug'
end
