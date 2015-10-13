#
# Cookbook Name:: chef-ha
# Recipe:: backend
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

# required
include_recipe 'chef-ha::rhel'
include_recipe 'chef-ha::drbd'
include_recipe 'nfs'
include_recipe 'nfs::server' if primary_node?(node['ipaddress'], node.chef_environment)
include_recipe 'chef-ha::chef'

# optional premium feature
include_recipe 'chef-ha::opscode-reporting'
