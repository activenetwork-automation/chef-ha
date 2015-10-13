[![Build Status](https://travis-ci.org/activenetwork-automation/chef-ha.svg)](https://travis-ci.org/activenetwork-automation/chef-ha) [![Dependency Status](https://gemnasium.com/activenetwork-automation/chef-ha.svg)](https://gemnasium.com/activenetwork-automation/chef-ha)

chef-ha cookbook
=================
This cookbook creates a Chef cluster in HA from beginning to end.

Local Requirements
------------
To test this locally, the following needs to be available:

* vagrant and plugins below
  * vagrant-triggers
  * vagrant-berkshelf
  * vagrant-ohai
  * vagrant-landrush
    * set the following entries via `vagrant landrush set <host> <ip>`
    * `chef-vip.vagrant.dev` 192.168.193.135 (back end vip)
    * `chef.vagrant.dev` 192.168.193.137 (front end entry point)

Also, this has only been tested against Centos 6.6.  This may work on other RHEL os's, but it has not been tested.

If everything is in place, you should be able to bring up your local cluster via:

`vagrant up chef1`

`vagrant up chef2`

`vagrant up chef3`

They are meant to run concurrently as they expect each other to be up before they can finish converging.  NFS is used on the bootstrap node to share out the configs.  The configs will only be reachable by the cluster machines which are defined in the chef_data data bag.

Setup
-----
When running this in your production environment, you'll need to do the following:

* edit `chef_data.json` to include your servers and desired environment(s)
  * ldap settings optional
* apply data bag to your chef server: `knife data bag from file chef_resources chef_data.json`
* provision nodes -- it shouldn't matter what order, however, nodes will not finish converging until the primary and secondary nodes finish their DRBD sync.

Usage
-----
#### chef-ha::rhel - required

This will remove ulimits and disable requiretty for rhel based os's.

---
#### chef-ha::drbd - required on backend nodes

This recipe needs to be applied to the back end nodes which need to be pre-defined in the data bag.

---
#### chef-ha::chef - required on all nodes

This recipe installs Chef in HA.  This requires that the primary node finishes first so that the configs can be shared out to the dependant nodes.  

---
#### chef-ha::opscode-manage - optional on front end nodes

This recipe installs the opscode-manage package on the front end node(s).  This package is optional and is free up to 25 nodes per Chef's License Agreement.

---
#### chef-ha::opscode-reporting - optional

This recipe installs the opscode-reporting package on the chef system.  If you want to install this pacakge, this recipe needs to be applied to all nodes.  This package is optional and is free up to 25 nodes per Chef's License Agreement.

---
#### chef-ha::backend

This recipe includes everything required on the back end nodes to create Chef in HA as well as the configuration of opscode reporting.

---
#### chef-ha::frontend

This recipe includes everything required on the front end node(s) to create Chef in HA as well as the configuration of opscode-reporting and opscode-reporting.

## Contributing

1. Fork it ( https://github.com/activenetwork-automation/chef-ha/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

### License and Authors

- [Joe Nguyen](https://github.com/joenguyen)

## License ##

|                      |                                          |
|:---------------------|:-----------------------------------------|
| **Copyright:**       | Copyright 2015 ACTIVE Network, LLC
| **License:**         | Apache License, Version 2.0

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
