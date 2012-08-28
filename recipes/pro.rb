#
# Cookbook Name:: nexus
# Recipe:: pro
#
# Copyright 2011, DTO Solutions, Inc.
# Copyright 2010, Opscode, Inc.
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
#
include_recipe "nexus::default"

nexus_license "install a nexus pro license"

nexus_proxy "enable smart proxy" do
  action :enable
  host   node[:nexus][:smart_proxy][:host]
  port   node[:nexus][:smart_proxy][:port]
  only_if { node[:nexus][:smart_proxy][:enable] }
end

node[:nexus][:repository][:publishers].each do |repository|

  nexus_repository repository do
    action      :update
    publisher   true
  end
end

node[:nexus][:repository][:subscribers].each do |repository|

  nexus_repository repository do
    action      :update
    subscriber  true
  end
end

data_bag_item = Chef::EncryptedDataBagItem.load('nexus', 'certificates')
node[:nexus][:smart_proxy][:trusted_servers].each do |server|
  server_info = data_bag_item[server]

  log "The server #{server} was not found in the data bag." do
    level :fatal
    only_if { server_info.nil? }
  end

  log "The data bag entry for #{server} requires a \"certificate\" element." do
    level :fatal
    only_if { server_info["certificate"].nil? }
  end

  log "The data bag entry for #{server} requires a \"description\" element." do
    level :fatal
    only_if { server_info["description"].nil? }
  end

  nexus_proxy "install a trusted key with description #{server_info["description"]}" do
    action      :add_trusted_key
    description server_info["description"]
    certificate server_info["certificate"]
  end
end