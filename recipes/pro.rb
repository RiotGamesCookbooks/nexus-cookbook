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

data_bag_item = Chef::Nexus.get_certificates_data_bag(node)
data_bag_item.to_hash.each do |key, value|

  unless key == "id"
    log "Trusting #{key}"
    nexus_proxy "install a trusted key with description #{value["description"]}" do
      action      :add_trusted_key
      description value["description"]
      certificate value["certificate"]
    end
  end
end