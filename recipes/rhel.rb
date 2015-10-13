#
# Cookbook Name:: chef-ha
# Recipe:: rhel
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

if platform_family?('rhel')
  # As of EC11.1.8, we need to disable sudo 'requiretty' on RHEL-based systems
  execute 'sudoers-disable-requiretty' do
    command 'sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers'
    action :run
    only_if 'grep "^Defaults.*requiretty" /etc/sudoers'
  end

  # RHEL and it's silly limits
  file '/etc/security/limits.d/90-nproc.conf' do
    action :delete
  end

  file '/etc/security/limits.d/10-nofile.conf' do
    action :create
    owner 'root'
    group 'root'
    mode '0644'
    content "*          soft    nofile     1048576\n*          hard    nofile     1048576"
  end
end
