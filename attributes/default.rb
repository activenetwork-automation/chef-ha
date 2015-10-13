# download links
default['active']['chef_ha']['chef_pkg'] = 'https://packagecloud.io/chef/stable/packages/el/6/chef-server-core-12.2.0-1.el6.x86_64.rpm/download'
default['active']['chef_ha']['reporting_pkg'] = 'https://packagecloud.io/chef/stable/packages/el/6/opscode-reporting-1.5.1-1.el6.x86_64.rpm/download'
default['active']['chef_ha']['manage_pkg'] = 'https://packagecloud.io/chef/stable/packages/el/6/opscode-manage-1.20.0-1.el6.x86_64.rpm/download'

# nfs defaults
default['active']['chef_ha']['nfs_options'] = ['no_root_squash']

# overrides
node.default['nfs']['packages'] = ['portmap', 'nfs-utils', 'nfs-utils-lib']
node.default['nfs']['port']['statd'] = 32765
node.default['nfs']['port']['statd_out'] = 32766
node.default['nfs']['port']['mountd'] = 32767
node.default['nfs']['port']['lockd'] = 32768
