#
# Copyright:: Copyright (c) 2012 Opscode, Inc.
# License:: Apache License, Version 2.0
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
#

bootstrap_status_file = "/var/opt/opscode-push-jobs-server/bootstrapped"
pushy_dir = "#{node['pushy']['install_path']}/embedded/service/opscode-pushy-server"

# JC - TODO when status is ready for pushy API
#execute "verify-system-status" do
#  command "curl -sf http://localhost:8000/_status"
#  retries 20
#  not_if { File.exists?(bootstrap_status_file) }
#end

file bootstrap_status_file do
  owner "root"
  group "root"
  mode "0600"
  content "All your bootstraps are belong to Pushy"
end
