#
# Cookbook Name:: chef-ha
# Spec:: opscode-manage
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

describe 'chef-ha::opscode-manage' do
  context 'When attributes are default, on CentOS 6.6' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.6'
      ) do |node|
        # Set/override attributes here
      end.converge(described_recipe)
    end

    let (:opscode_manage) { chef_run.remote_file('opscode-manage') }
    it 'downloads opscode-manage package' do
      expect(chef_run).to create_remote_file('opscode-manage')
      expect(opscode_manage).to notify('package[opscode-manage]').to(:install).immediately
    end

    let (:install_opscode_manage) { chef_run.package('opscode-manage') }
    it 'installs opscode-manage rpm' do
      expect(chef_run).not_to install_package('opscode-manage')
      expect(install_opscode_manage).to notify('ruby_block[configure-opscode-manage]').to(:run).immediately
    end

    it 'runs ruby_block configure-opscode-manage' do
      expect(chef_run).not_to run_ruby_block('configure-opscode-manage')
    end

  end
end
