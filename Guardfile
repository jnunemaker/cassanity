# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end

guard 'rspec', :version => 2 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$}) { |m| [
    "spec/unit/#{m[1]}_spec.rb",
    "spec/integration/#{m[1]}_spec.rb",
  ] }
  watch('spec/helper.rb')  { "spec" }
end

