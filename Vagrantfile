VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # global defaults
  config.berkshelf.enabled = true
  config.landrush.enabled = true

  config.vm.box = 'boxcutter/centos66'
  domain = '.vagrant.dev'

  chef_servers = [
    { 'name' => 'chef1', 'ip' => '192.168.193.129', 'role' => 'chef-ha-primary' },
    { 'name' => 'chef2', 'ip' => '192.168.193.130', 'role' => 'chef-ha-secondary' },
    { 'name' => 'chef3', 'ip' => '192.168.193.137', 'role' => 'chef-ha-frontend' }
  ]

  # bring up chef servers
  chef_servers.each do |chef_server|
    config.vm.define chef_server['name'] do |chef|
      # set server defaults
      chef.vm.host_name = chef_server['name'] + domain
      chef.vm.network 'private_network', ip: chef_server['ip']

      # create dedicated disk for back end server(s)
      if ['chef1', 'chef2'].include?(chef_server['name'])

        # vmware_fusion provider defaults
        config.vm.provider :vmware_fusion do |vm|
          vdiskmanager = '/Applications/VMware\ Fusion.app/Contents/Library/vmware-vdiskmanager'
          dir = "#{ENV['PWD']}/.vagrant/additional-disks"
          Dir.mkdir dir unless File.directory?( dir )

          file_to_disk = "#{dir}/#{chef_server['name']}_hd2.vmdk"
          `#{vdiskmanager} -c -s 4GB -a lsilogic -t 0 #{file_to_disk}` unless File.exists?( file_to_disk )

          vm.vmx['scsi0:1.filename'] = file_to_disk
          vm.vmx['scsi0:1.present']  = 'TRUE'
          vm.vmx['scsi0:1.redo']     = ''
        end

        # virtualbox provider defaults
        config.vm.provider :virtualbox do |vb|
          dir = "#{ENV['PWD']}/.vagrant/additional-disks"
          file_to_disk = "#{dir}/#{chef_server['name']}_hd2.vmdk"
          unless File.exist?(file_to_disk)
            vb.customize ['createhd', '--filename', file_to_disk, '--format', 'VDI', '--size', 4 * 1024]
          end
          vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
        end

        # clean up
        chef.trigger.after :destroy, :force => true do
          info 'Cleaning up additional disk(s)..'
          run "rm #{ENV['PWD']}/.vagrant/additional-disks/#{chef_server['name']}_hd2.vmdk"
        end
      end

      # converge chef
      chef.vm.provision :chef_solo do |chef|
        chef.cookbooks_path     = '..'
        chef.data_bags_path     = 'test/chef/data_bags'
        chef.roles_path         = 'test/chef/roles'
        chef.environments_path  = 'test/chef/environments'
        chef.environment        = 'local'
        chef.add_role             chef_server['role']
      end
    end
  end
end
