require 'bundler'
require 'rubocop/rake_task'
require 'foodcritic'
require 'rspec/core/rake_task'
require 'chef/knife'

desc 'Run all tests except Kitchen (default task)'
task integration: %w(rubocop foodcritic spec)
task default: :integration

desc 'Run linters'
task lint: [:rubocop, :foodcritic]

desc 'Run all tests'
task test: [:integration]

# ChefSpec
desc 'Run ChefSpec tests'
task :spec do
  puts 'Running chefspec tests...'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w(--color)
  end
end

# Foodcritic
desc 'Run foodcritic lint checks'
task :foodcritic do
  puts 'Running foodcritic...'
  FoodCritic::Rake::LintTask.new
  # puts 'Running Foodcritic tests...'
  # FoodCritic::Rake::LintTask.new do |t|
  #   t.options = { fail_tags: ['any'] }
  #   puts 'done.'
  # end
end

# Rubocop
desc 'Run Rubocop lint checks'
task :rubocop do
  RuboCop::RakeTask.new
end
