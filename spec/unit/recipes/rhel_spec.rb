#
# Cookbook Name:: chef-ha
# Spec:: rhel
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

describe 'chef-ha::rhel' do
  context 'When all attributes are default, on CentOS 6.6' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '6.6'
      ) do |node|
        # Set/override attributes here
        # node.automatic['virtualization']['role'] = 'guest'
      end
      runner.converge(described_recipe)
    end

    before do
       stub_command("grep \"^Defaults.*requiretty\" /etc/sudoers").and_return('Defaults.*requiretty')
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end

    it 'executes sudoers-disable-requiretty' do
      expect(chef_run).to run_execute('sudoers-disable-requiretty')
    end

    it 'deletes /etc/security/limits.d/90-nproc.conf' do
      expect(chef_run).to delete_file('/etc/security/limits.d/90-nproc.conf')
    end

    it 'creates /etc/security/limits.d/10-nofile.conf' do
      expect(chef_run).to create_file('/etc/security/limits.d/10-nofile.conf').with(
        owner: 'root',
        group: 'root',
        mode: '0644',
        content: "*          soft    nofile     1048576\n*          hard    nofile     1048576"
      )
    end
  end
end
