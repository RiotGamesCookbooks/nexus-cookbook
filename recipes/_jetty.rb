#
# Cookbook Name:: nexus
# Recipe:: _jetty
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
ssl_files = Chef::Nexus.get_ssl_files_data_bag(node)

if ssl_files && ssl_files[node[:nexus][:jetty_keystore][:key]]
  ssl_files_for_node = ssl_files[node[:nexus][:app_server_proxy][:ssl][:key]]
  keystore_value = ssl_files_for_node[:keystore]
  
  log "Using nexus_ssl_files data bag entry for #{node[:nexus][:ssl_certificate][:key]}" do
    level :info
  end

  Chef::Application.fatal! "nexus_ssl_files data bag item is missing a 'keystore' key for #{node[:nexus][:jetty_keystore][:key]}" unless keystore_value

  directory node[:nexus][:ssl][:jetty_keystore_path] do
    owner     node[:nexus][:user]
    group     node[:nexus][:group]
    mode      "0755"
    action    :create
    recursive true
  end

  file "#{node[:nexus][:ssl][:jetty_keystore_path]}/keystore" do
    owner   node[:nexus][:user]
    group   node[:nexus][:group]
    mode    "0755"
    content Chef::Nexus.decode(keystore_value)
    action  :create
  end
end
