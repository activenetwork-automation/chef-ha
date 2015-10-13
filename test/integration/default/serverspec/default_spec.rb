require 'spec_helper'

describe 'scm-gitlab-ha::default' do
  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html

  # ssl keys
  Dir.glob('/etc/gitlab/ssl/*.key') do |ssl_key|
    describe file(ssl_key) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 640 }
    end

    describe x509_private_key(ssl_key) do
      it { should_not be_encrypted }
      it { should be_valid }
    end
  end

  # ssl certs
  Dir.glob('/etc/gitlab/ssl/*.crt') do |ssl_crt|
    describe file(ssl_crt) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 640 }
    end

    describe x509_certificate(ssl_crt) do
      it { should be_valid }
      it { should be_certificate }
    end
  end

  # required package installs
  ['gitlab-ee', 'drbd84-utils', 'kmod-drbd84', 'nfs-utils', 'rpcbind', 'psmisc'].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

  # gitlab configuration
  describe file('/etc/gitlab/gitlab.rb') do
    it { should be_file }
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
  end

  # gitlab install
  describe file('/tmp/gitlab-ee-7.12.0~ee.omnibus.1-1.x86_64.rpm') do
    it { should be_file }
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/tmp/drbd84-utils-8.9.2-1.el6.elrepo.x86_64.rpm') do
    it { should be_file }
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end

  describe file('/tmp/kmod-drbd84-8.4.6-1.el6.elrepo.x86_64.rpm') do
    it { should be_file }
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
  # prereq service
  describe service('postfix') do
    it { should be_running }
  end

  # check gitlab-ctl command
  describe command('gitlab-ctl show-config') do
    its(:stdout) { should contain('high-availability') }
    its(:stdout) { should contain('gitlab_ci_https') }
    its(:stdout) { should contain('postgresql') }
    its(:stdout) { should contain('backup_keep_time') }
  end

  # check cron file
  describe file('/etc/cron.d/gitlab_backup') do
    it { should be_file }
    it { should exist }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    it { should be_mode 644 }
    it { should contain '0 2 * * * root gitlab-rake gitlab:backup:create' }
  end

  # check gitlab-drbd home
  describe file('/opt/gitlab-drbd/bin') do
    it { should be_directory }
  end

  # check gitlab-drbd command
  describe file('/opt/gitlab-drbd/bin/gitlab-drbd') do
    it { should be_file }
  end

  # check gitlab-drbd home
  describe file('/usr/bin/gitlab-drbd') do
    it { should be_symlink }
  end

  # check drbd conf
  describe file('/etc/gitlab-drbd.conf') do
    it { should be_file }
  end

  # check gitlab-drbd command
  describe file('/etc/gitlab/skip-auto-migrations') do
    it { should be_file }
    it { should exist }
  end

  # check gitlab home
  describe file('/var/opt/gitlab') do
    it { should be_directory }
  end

  # check drbd global config
  describe file('/etc/drbd.d/global_common.conf') do
    it { should contain 'usage-count no' }
  end

  # check gitlab_data
  describe file('/etc/drbd.d/gitlab_data.res') do
    it { should be_file }
  end

  # check drbd
  (0..15).each do |n|
    describe file("/dev/drbd#{n}") do
      it { should be_block_device }
    end
  end

  # check that /tmp was bind-mounted to /var/opt/gitlab/backups
  describe file('/var/opt/gitlab/backups') do
    it { should be_directory }
  end

  describe file('/etc/fstab') do
    its(:content) { should match(%r{/tmp /var/opt/gitlab/backups none bind 0 0}) }
    its(:content) { should match(%r{/tmp /var/opt/gitlab/ci-backups none bind 0 0}) }
  end
end
