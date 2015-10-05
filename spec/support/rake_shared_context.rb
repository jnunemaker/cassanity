require "rake"

shared_context "rake" do
  let(:rake)      { Rake::Application.new }
  let(:task_name) { self.class.top_level_description }
  let(:task_path) { "#{task_name.split(":").first}" }
  subject         { rake[task_name] }

  let(:all_tasks_path) { Pathname.new File.expand_path('../../../lib/tasks', __FILE__) }

  def loaded_files_excluding_current_rake_file
    # Remove the tested file from the loaded paths
    $".reject {|file| file == all_tasks_path.join("#{task_path}.rake").to_s }
  end

  before do
    Rake.application = rake
    Rake.application.rake_require(task_path, [all_tasks_path.to_s], loaded_files_excluding_current_rake_file)

    Rake::Task.define_task(:environment)
  end
end
