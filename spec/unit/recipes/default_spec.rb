#
# Cookbook Name:: chef-ha
# Spec:: default
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

describe 'chef-ha::default' do
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

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end

  context 'When all attributes are default, on Windows 2008R2' do
    let(:chef_run) do
      runner = ChefSpec::SoloRunner.new(
        platform: 'windows',
        version: '2008R2'
      ) do |node|
        # Set/override attributes here
        # node.automatic['virtualization']['role'] = 'guest'
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run # This should not raise an error
    end
  end
end
