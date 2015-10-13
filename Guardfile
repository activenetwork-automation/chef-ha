# A sample Guardfile
# More info at https://github.com/guard/guard#readme

notification :growl, sticky: true

guard :foodcritic, :cookbook_paths => ".", :all_on_start => true do
  watch(%r{attributes/.+\.rb$})
  watch(%r{providers/.+\.rb$})
  watch(%r{recipes/.+\.rb$})
  watch(%r{resources/.+\.rb$})
  watch('metadata.rb')
end

guard :rubocop do
  watch(%r{.+\.rb$})
  watch(%r{attributes/.+\.rb$})
  watch(%r{providers/.+\.rb$})
  watch(%r{recipes/.+\.rb$})
  watch(%r{resources/.+\.rb$})
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{(?:.+/)?\.rubocop\.yml$}) { |m| File.dirname(m[0]) }
end

guard :rspec, cmd: 'bundle exec rspec', :all_on_start => true do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^(recipes)/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard :kitchen do
  watch(%r{test/.+})
  watch(%r{^recipes/(.+)\.rb$})
  watch(%r{^attributes/(.+)\.rb$})
  watch(%r{^files/(.+)})
  watch(%r{^templates/(.+)})
  watch(%r{^providers/(.+)\.rb})
  watch(%r{^resources/(.+)\.rb})
end
