#
# Cookbook Name:: chef-ha
# Spec:: drbd
#
# Copyright (c) 2015 The Active Network
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

require 'spec_helper'

describe 'chef-ha::chef' do
  context 'When attributes are default, on CentOS 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.6'
      ) do |node|
        # Set/override attributes here
        env = Chef::Environment.new
        env.name 'local'

        # Stub the node to return this environment
        allow(node).to receive(:chef_environment).and_return(env.name)

        # Stub any calls to Environment.load to return this environment
        allow(Chef::Environment).to receive(:load).and_return(env)
      end.converge(described_recipe)
    end

    before do
      # read in data bag file
      file = ::File.read('test/chef/data_bags/chef_resources/chef_data.json')

      # stub data bag
      stub_data_bag_item('chef_resources', 'chef_data').and_return(::JSON.parse(file))

      # stub getent guard
      stub_command('getent passwd opscode').and_return(false)
    end

    it 'creates initial chef directories' do
      %w(/etc/opscode /var/chef/cache/opscode-configs).each do |dir|
        expect(chef_run).to create_directory(dir).with(
          owner: 'root',
          group: 'root'
        )
      end
    end

    it 'creates /etc/opscode/chef-server.rb template' do
      expect(chef_run).to create_template('/etc/opscode/chef-server.rb')
    end

    let (:chef_server) { chef_run.remote_file('chef-server') }
    it 'downloads chef-server package' do
      expect(chef_run).to create_remote_file('chef-server')
      expect(chef_server).to notify('package[chef-server]').to(:install).immediately
    end

    let (:chef_server_install) { chef_run.package('chef-server') }
    it 'installs chef-server package' do
      expect(chef_run).not_to install_package('chef-server')
      expect(chef_server_install).to notify('ruby_block[initial-reconfigure]').to(:run).immediately
    end

    it 'runs wait-chef-configs ruby_block' do
      expect(chef_run).to run_ruby_block('wait-chef-configs')
    end

    it 'runs initial-reconfigure ruby_block' do
      expect(chef_run).not_to run_ruby_block('initial-reconfigure')
    end

    it 'creates /etc/opscode nfs_export' do
      expect(chef_run).not_to create_nfs_export('/etc/opscode')
    end

    it 'runs copy-configs ruby_block' do
      expect(chef_run).to run_ruby_block('copy-configs')
    end

    it 'runs final-reconfigure ruby_block' do
      expect(chef_run).to run_ruby_block('final-reconfigure')
    end

  end
end
