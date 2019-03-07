# vim: tabstop=2:shiftwidth=2:softtabstop=2
#
# Cookbook Name:: bcpc
# Recipe:: grub.rb
#
# Copyright 2018, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Legacy NIC names for most machines
subnet = node['bcpc']['management']['subnet']
ifnames = ''
unless node['bcpc']['networks'][subnet]['management']['legacy_names'] == false
  ifnames = 'net.ifnames=0 biosdevname=0 ' # Leave the trailing space
end

template '/etc/default/grub' do
  source 'grub/etc_default_grub.erb'
  owner 'root'
  group 'root'
  mode 0o0644
  variables(ifnames: ifnames)
  notifies :run, 'execute[update-grub]'
end

execute 'update-grub' do
  command '/usr/sbin/update-grub'
  user 'root'
  action :nothing
end

# List of serial consoles to configure (ttySX)
sconsoles = node['bcpc']['grub']['serial']['consoles']

# Create getty upstart configuration for all
# FIXME: Rewrite this block when moving to 16.04/18.04
sconsoles.each do |console|
  template "/etc/init/#{console}.conf" do
    source 'grub/ttySX.conf.erb'
    owner 'root'
    group 'root'
    mode 0o0644
    variables(
      console: console
    )
    notifies :run, 'execute[initctl_reloadconfig]', :immediate
    notifies :restart, "service[#{console}]", :delayed
  end

  execute 'initctl_reloadconfig' do
    command '/sbin/initctl reload-configuration'
    action :nothing
  end

  service console do
    supports status: true, restart: true, reload: false
    action [:start, :enable]
  end
end
