require "bundler/gem_tasks"

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

task :default => :spec

namespace :spec do
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = './spec/integration/**/*_spec.rb'
  end

  RSpec::Core::RakeTask.new(:unit) do |t|
    t.pattern = './spec/unit/**/*_spec.rb'
  end
end
