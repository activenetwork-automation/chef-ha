# Get the ip of the primary backend node from the databag
# @param [String] env chef_environment
# @return [String] ip
def get_primary_ip(env = nil)
  chef_data = data_bag_item('chef_resources', 'chef_data')
  ip = nil
  chef_data[env]['machines'].each do |entry|
    if entry['bootstrap'] == 'true'
      ip = entry['ip']
      break
    end
  end
  ip
end

# Test to see if the ip is the primary bootstrap node
# @param [String] ip
# @param [String] env chef_environment
# @return [bool]
def primary_node?(ip = nil, env = nil)
  get_primary_ip(env) == ip ? true : false
end

# Get array of ip's for NFS security
# @param [String] env chef_environment
# @return [STring] array of ip's
def get_nfs_ips(env = nil)
  chef_data = data_bag_item('chef_resources', 'chef_data')
  ips = []
  chef_data[env]['machines'].each do |entry|
    ips << entry['ip'] unless entry['bootstrap'] == 'true' || entry['role'] == 'backend_vip'
  end
  ips
end
