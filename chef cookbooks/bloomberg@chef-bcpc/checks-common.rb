#
# Cookbook Name:: bcpc
# Recipe:: checks-common
#
# Copyright 2016, Bloomberg Finance L.P.
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

directory "/usr/local/bin/checks" do
  action :create
  owner "root"
  group "root"
  mode 00775
end

directory "/usr/local/etc/checks" do
  action :create
  owner "root"
  group "root"
  mode 00775
end

 template  "/usr/local/etc/checks/default.yml" do
   source "checks/default.yml.erb"
   owner "root"
   group "root"
   mode 00640
 end

 cookbook_file "/usr/local/bin/check" do
   source "checks/check"
   owner "root"
   mode "00755"
 end

%w{ nova }.each do |cc|
  template  "/usr/local/etc/checks/#{cc}.yml" do
    source "checks/#{cc}.yml.erb"
    owner "root"
    group "root"
    mode 00640
  end

  cookbook_file "/usr/local/bin/checks/#{cc}" do
    source "checks/#{cc}"
    owner "root"
    mode "00755"
  end
end

