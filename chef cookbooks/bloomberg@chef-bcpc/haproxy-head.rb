#
# Cookbook Name:: bcpc
# Recipe:: haproxy-head
#
# Copyright 2013, Bloomberg Finance L.P.
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

include_recipe "bcpc::default"
# There is cyclical dependency upon some of checks - see /etc/xinetd.d/*chk
include_recipe "bcpc::xinetd"
include_recipe "bcpc::haproxy-common"

concat_fragment "haproxy-main-config" do
  order  "001"
  target "/etc/haproxy/haproxy.cfg"
  source "haproxy-head.cfg.erb"
  variables(
    lazy {
      {
        :servers => get_head_nodes,
        :mysql_max_connections => get_mysql_max_connections,
      }
    }
  )
end

concat "/etc/haproxy/haproxy.cfg" do
  mode 00644
  owner 'root'
  group 'root'
  notifies :restart, "service[haproxy]", :immediately
  notifies :restart, "service[xinetd]", :immediately
end
