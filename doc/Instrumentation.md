# Instrumentation

Cassanity comes with a log subscriber and automatic metriks or statsd instrumentation.
By default these work with ActiveSupport::Notifications, but only require the
pieces of ActiveSupport that are needed and only do so if you actually attempt
to require the instrumentation files listed below.

To use the log subscriber:

```ruby
# Gemfile
gem 'activesupport'

# config/initializers/cassanity.rb (or wherever you want it)
require 'cassanity/instrumentation/log_subscriber'
```

To use the metriks instrumentation:

```ruby
# Gemfile
gem 'activesupport'
gem 'metriks'

# config/initializers/cassanity.rb (or wherever you want it)
require 'cassanity/instrumentation/metriks'
```

To use the statsd instrumentation:

```ruby
# Gemfile
gem 'activesupport'
gem 'statsd-ruby'

# config/initializers/cassanity.rb (or wherever you want it)
require 'cassanity/instrumentation/statsd'

Cassanity::Instrumentation::StatsdSubscriber.client = Statsd.new
```
