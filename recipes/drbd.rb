#
# Cookbook Name:: chef-ha
# Recipe:: drbd
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

# set up elrepo
ruby_block 'set-up-elrepo' do
  block do
    cmd = Mixlib::ShellOut.new('rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org')
    cmd.run_command
    cmd = Mixlib::ShellOut.new('rpm -Uvh http://www.elrepo.org/elrepo-release-6-6.el6.elrepo.noarch.rpm')
    cmd.run_command
  end
end

# install required packages
package 'drbd84-utils'
package 'kmod-drbd84'

# create drbd dirs
DRBD_DIR = '/var/opt/opscode/drbd'
DRBD_ETC_DIR =  ::File.join(DRBD_DIR, 'etc')
DRBD_DATA_DIR = ::File.join(DRBD_DIR, 'data')

[DRBD_DIR, DRBD_ETC_DIR, DRBD_DATA_DIR].each do |dir|
  directory dir do
    recursive true
    mode '0755'
  end
end

# create resource
chef_data = data_bag_item('chef_resources', 'chef_data')
template "#{DRBD_ETC_DIR}/pc0.res" do
  mode '0655'
  owner 'root'
  group 'root'
  source 'pc0.res.erb'
  action :create_if_missing
  variables chef_data[node.chef_environment].to_hash
end

# create conf
cookbook_file "#{DRBD_ETC_DIR}/drbd.conf" do
  source 'drbd.conf'
  owner 'root'
  group 'root'
  mode '0655'
  action :create_if_missing
end

# create links
execute 'backup-drbd-conf' do
  command 'mv /etc/drbd.conf /etc/drbd.conf.orig'
  only_if { ::File.exist?('/etc/drbd.conf') && !::File.symlink?('/etc/drbd.conf') }
end

link '/etc/drbd.conf' do
  to ::File.join("#{DRBD_ETC_DIR}/drbd.conf")
end

# create logical volume
bash 'configure-drbd' do
  user 'root'
  code <<-EOH
    pvcreate /dev/sdb
    vgcreate opscode /dev/sdb
    lvcreate -l 80%VG -n drbd opscode
  EOH
  not_if { ::File.exist?('/dev/mapper/opscode-drbd') }
  notifies :run, 'execute[drbdadm-create]', :immediately
end

# drbd create
execute 'drbdadm-create' do
  command 'drbdadm create-md pc0'
  action :nothing
  notifies :run, 'execute[drbdadm-up]', :immediately
end

# drbd activate
execute 'drbdadm-up' do
  command 'drbdadm up pc0'
  action :nothing
  notifies :run, 'execute[drbdadm-primary]', :immediately
  notifies :run, 'ruby_block[wait-drbd-sync]', :immediately
end

# force primary primary node to be master
execute 'drbdadm-primary' do
  command 'drbdadm primary --force pc0; mkfs.ext4 /dev/drbd0; \
           mkdir -p /var/opt/opscode/drbd/data; \
           mount /dev/drbd0 /var/opt/opscode/drbd/data'
  action :nothing
  only_if { primary_node?(node['ipaddress'], node.chef_environment) }
end

# wait for drbd to sync
ruby_block 'wait-drbd-sync' do
  block do
    true until `grep "ds:UpToDate/UpToDate" /proc/drbd` != ''
  end
  action :nothing
  notifies :create, 'file[drbd_ready]', :immediately
end

# sync complete
file 'drbd_ready' do
  path '/var/opt/opscode/drbd/drbd_ready'
  action :nothing
end
