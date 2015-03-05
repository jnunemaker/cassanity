require 'rake'

module Cassanity
  class RakeTasks
    include Rake::DSL if defined? Rake::DSL
    def install_tasks
       load 'tasks/cassanity.rake'
    end
  end
end
Cassanity::RakeTasks.new.install_tasks
