#
# Copyright 2017, Bloomberg Finance L.P.
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

#
# The upstream maven cookbook has a non-functioning maven 1.x URL
# configured as the default value, so we are obliged to override it.
#
default['maven']['repositories'] = ['http://repo1.maven.apache.org/maven2']

# This is used in a maven_settings resource to configure plugin repos.
default[:bach][:maven][:central_mirror] = nil
