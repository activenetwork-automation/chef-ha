#
# Cookbook Name:: chef-ha
# Recipe:: opscode-manage
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

# default
package_url = node.default['active']['chef_ha']['manage_pkg']
package_name = 'opscode-manage.rpm'
package_path = ::File.join(Chef::Config['file_cache_path'], package_name)

# download
remote_file 'opscode-manage' do
  path package_path
  source package_url
  notifies :install, 'package[opscode-manage]', :immediately
end

# install
package 'opscode-manage' do
  source package_path
  action :nothing
  notifies :run, 'ruby_block[configure-opscode-manage]', :immediately
end

ruby_block 'configure-opscode-manage' do
  block do
    cmd = Mixlib::ShellOut.new('chef-server-ctl reconfigure; \
                                opscode-manage-ctl reconfigure', live_stream: STDOUT)
    cmd.run_command
  end
  action :nothing
end
