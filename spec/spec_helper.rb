# Added by ChefSpec
require 'chefspec'
require 'chefspec/berkshelf'
require_relative 'support/matchers'

# Uncomment to use ChefSpec's Berkshelf extension
ChefSpec::Coverage.start!

RSpec.configure do |config|
  # Specify the path for Chef Solo to find cookbooks
  # config.cookbook_path = '/var/cookbooks'

  # Specify the path for Chef Solo to find roles
  # config.role_path = '/var/roles'

  # Specify the path for Chef Solo file cache path (default: nil)
  config.file_cache_path = '/var/chef/cache'

  # Specify the Chef log_level (default: :warn)
  # config.log_level = :debug

  # Specify the path to a local JSON file with Ohai data
  # config.path = 'ohai.json'

  # Specify the operating platform to mock Ohai data from
  # config.platform = 'ubuntu'

  # Specify the operating version to mock Ohai data from
  # config.version = '12.04'

end
