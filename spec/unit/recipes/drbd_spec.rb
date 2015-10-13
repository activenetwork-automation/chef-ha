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

describe 'chef-ha::drbd' do
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

    it 'runs set-up-elrepo ruby block' do
      expect(chef_run).to run_ruby_block('set-up-elrepo')
    end

    it 'installs drbd required packages' do
      expect(chef_run).to install_package('drbd84-utils')
      expect(chef_run).to install_package('kmod-drbd84')
    end

    it 'creates default drbd directories' do
      %w(/var/opt/opscode/drbd /var/opt/opscode/drbd/etc /var/opt/opscode/drbd/data).each do |dir|
        expect(chef_run).to create_directory(dir)
      end
    end

    it 'creates /var/opt/opscode/drbd/etc/pc0.res template' do
      expect(chef_run).to create_template_if_missing('/var/opt/opscode/drbd/etc/pc0.res')
    end

    it 'creates /var/opt/opscode/drbd/etc/drbd.conf file' do
      expect(chef_run).to create_cookbook_file_if_missing('/var/opt/opscode/drbd/etc/drbd.conf')
    end

    it 'executes backing up drbd.conf' do
      expect(chef_run).not_to run_execute('backup-drbd-conf')
    end

    it 'creates /etc/drbd.conf link' do
      expect(chef_run).to create_link('/etc/drbd.conf')
    end

    let (:configure_drbd) { chef_run.bash('configure-drbd') }
    it 'runs configure-drbd bash' do
      expect(chef_run).to run_bash('configure-drbd')
      expect(configure_drbd).to notify('execute[drbdadm-create]').to(:run).immediately
    end

    let (:drbdadm_create) { chef_run.execute('drbdadm-create') }
    it 'executes drbdadm-create' do
      expect(chef_run).not_to run_execute('drbdadm-create')
      expect(drbdadm_create).to notify('execute[drbdadm-up]').to(:run).immediately
    end

    let (:drbdadm_up) { chef_run.execute('drbdadm-up') }
    it 'executes drbdadm-up' do
      expect(chef_run).not_to run_execute('drbdadm-up')
      expect(drbdadm_up).to notify('execute[drbdadm-primary]').to(:run).immediately
      expect(drbdadm_up).to notify('ruby_block[wait-drbd-sync]').to(:run).immediately
    end

    it 'executes drbdadm-primary' do
      expect(chef_run).not_to run_execute('drbdadm-primary')
    end

    it 'runs wait-drbd-sync ruby_block' do
      expect(chef_run).not_to run_ruby_block('wait-drbd-sync')
    end

    it 'creates drbd_ready file' do
      expect(chef_run).not_to create_file('drbd_ready')
    end

  end
end
