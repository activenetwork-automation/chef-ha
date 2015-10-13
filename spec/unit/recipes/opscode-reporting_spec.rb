#
# Cookbook Name:: chef-ha
# Spec:: opscode-reporting
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

describe 'chef-ha::opscode-reporting' do
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
    end

    it 'creates initial opscode-reporting directories' do
      %w(/etc/opscode-reporting /var/chef/cache/opscode-reporting-configs).each do |dir|
        expect(chef_run).to create_directory(dir).with(
          owner: 'root',
          group: 'root'
        )
      end
    end

    let (:opscode_reporting_file) { chef_run.remote_file('opscode-reporting') }
    it 'creates opscode-reporting remote_file' do
      expect(chef_run).to create_remote_file('opscode-reporting')
      expect(opscode_reporting_file).to notify('package[opscode-reporting]').to(:install).immediately
    end

    let (:opscode_reporting_install) { chef_run.package('opscode-reporting') }
    it 'installs opscode-reporting package' do
      expect(chef_run).not_to install_package('opscode-reporting')
      expect(opscode_reporting_install).to notify('ruby_block[initial-reconfigure]').to(:run).immediately
      expect(opscode_reporting_install).to notify('ruby_block[final-reconfigure]').to(:run).delayed
    end

    it 'runs wait-reporting-configs ruby_block' do
      expect(chef_run).to run_ruby_block('wait-reporting-configs')
    end

    it 'creates /etc/opscode-reporting nfs_export' do
      expect(chef_run).not_to create_nfs_export('/etc/opscode-reporting')
    end

  end
end
