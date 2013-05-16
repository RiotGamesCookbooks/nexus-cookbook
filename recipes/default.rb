#
# Cookbook Name:: nexus
# Recipe:: default
#
# Author:: Kyle Allan (<kallan@riotgames.com>)
# Copyright 2013, Riot Games
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
include_recipe "nexus::cli"
include_recipe "nexus::_ssl"
include_recipe "nexus::app"

data_bag_item = Chef::Nexus.get_credentials(node)
default_credentials = data_bag_item["default_admin"]
updated_credentials = data_bag_item["updated_admin"]

nexus_user "admin" do
  old_password default_credentials["password"]
  password     updated_credentials["password"]
  action       :change_password
  notifies :create, "ruby_block[set flag that default admin credentials were changed]", :immediately
  only_if { updated_credentials }
end

ruby_block "set flag that default admin credentials were changed" do
  block do
    node.set[:nexus][:cli][:default_admin_credentials_updated] = true
  end
  action :nothing
end
