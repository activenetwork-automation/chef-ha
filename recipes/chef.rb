#
# Cookbook Name:: chef-ha
# Recipe:: chef
#
# Copyright 2015 The Active Network
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# create default dirs
cache_configs_path = ::File.join(Chef::Config['file_cache_path'], 'opscode-configs')
local_configs_path = '/etc/opscode'
[local_configs_path, cache_configs_path].each do |dir|
  directory dir do
    user 'root'
    group 'root'
    action :create
    recursive true
  end
end

# create chef-server.rb from environment data bag
chef_data = data_bag_item('chef_resources', 'chef_data')
template "#{local_configs_path}/chef-server.rb" do
  source 'chef-server.rb.erb'
  action :create
  variables chef_data[node.chef_environment].to_hash
end

# defaults
package_url = node.default['active']['chef_ha']['chef_pkg']
package_name = 'chef-server.rpm'
package_path = ::File.join(Chef::Config['file_cache_path'], package_name)

# download
remote_file 'chef-server' do
  path package_path
  source package_url
  notifies :install, 'package[chef-server]', :immediately
end

# install
package 'chef-server' do
  source package_path
  action :nothing
  notifies :run, 'ruby_block[initial-reconfigure]', :immediately
end

# put nodes into a holding pattern until configs are copied out
ruby_block 'wait-chef-configs' do
  block do
    begin
      cmd = Mixlib::ShellOut.new("mount #{get_primary_ip(node.chef_environment)}:#{local_configs_path} #{cache_configs_path}")
      cmd.run_command
    end until ::File.exist?(::File.join(cache_configs_path, 'pivotal.pem'))
  end
  not_if { primary_node?(node['ipaddress'], node.chef_environment) }
end

# reconfigure on primary node
ruby_block 'initial-reconfigure' do
  block do
    cmd = Mixlib::ShellOut.new("chef-server-ctl reconfigure; \
                                chown -R root:root #{local_configs_path}", live_stream: STDOUT)
    cmd.run_command
  end
  action :nothing
  only_if { primary_node?(node['ipaddress'], node.chef_environment) }
end

# share configs
nfs_export local_configs_path do
  network get_nfs_ips(node.chef_environment)
  writeable false
  sync true
  options node.default['active']['chef_ha']['nfs_options']
  only_if { primary_node?(node['ipaddress'], node.chef_environment) }
end

# copy configs to all nodes
ruby_block 'copy-configs' do
  block do
    cmd = Mixlib::ShellOut.new("cp -R #{cache_configs_path}/* #{local_configs_path}/", live_stream: STDOUT)
    cmd.run_command
  end
  not_if { primary_node?(node['ipaddress'], node.chef_environment) }
end

# reconfigure
ruby_block 'final-reconfigure' do
  block do
    cmd = Mixlib::ShellOut.new('chef-server-ctl reconfigure', live_stream: STDOUT)
    cmd.run_command
  end
  not_if 'getent passwd opscode'
end
