name             'chef-ha'
maintainer       'Active Network'
maintainer_email 'joe.nguyen@activenetwork.com'
license          'Apache 2.0'
description      'Installs/Configures Chef in high availibility'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'nfs', '~> 2.2.4'

supports 'redhat'

source_url 'https://github.com/activenetwork-automation/chef-ha'
issues_url 'https://github.com/activenetwork-automation/chef-ha/issues'
