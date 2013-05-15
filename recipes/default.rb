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

include_recipe "build-essential"

directory node[:nexus][:mount][:nfs][:mount_point] do
  owner     node[:nexus][:user]
  group     node[:nexus][:group]
  mode      "0755"
  action    :create
  recursive true
  only_if   {node[:nexus][:mount][:nfs][:enable]}
end

mount "#{node[:nexus][:mount][:nfs][:mount_point]}" do
  action  [:mount, :enable]
  device  node[:nexus][:mount][:nfs][:device_path]
  fstype  "nfs"
  options "rw"
  only_if {node[:nexus][:mount][:nfs][:enable]}
end

jetty_ssl = nil

if node[:nexus][:ssl][:nginx] && node[:nexus][:ssl][:jetty]
  Chef::Application.fatal! "Cannot have both nginx and Jetty configured to use SSL for Nexus."
elsif node[:nexus][:ssl][:nginx]
  include_recipe "nexus::nginx"
elsif node[:nexus][:ssl][:jetty]
  credentials = Chef::Nexus.get_credentials(node)

  jetty_ssl = {
    :keystore_path  => node[:nexus][:ssl][:jetty_keystore_path],
    :ssl_port       => node[:nexus][:ssl][:port],
    :password       => credentials[:keystore][:password],
    :key_password   => credentials[:keystore][:key_password],
    :trust_password => credentials[:keystore][:trust_password]
  }

  include_recipe "nexus::jetty"
end



if node[:nexus][:ssl][:nginx]
  service "nginx" do
    action :restart
  end
end

data_bag_item = Chef::Nexus.get_credentials(node)
default_credentials = data_bag_item["default_admin"]
updated_credentials = data_bag_item["updated_admin"]

nexus_user "admin" do
  old_password default_credentials["password"]
  password     updated_credentials["password"]
  action       :change_password
end

ruby_block "set flag that default admin credentials were changed" do
  block do
    node.set[:nexus][:cli][:default_admin_credentials_updated] = true
  end
end

template ::File.join(node[:nexus][:work_dir], "conf", "logback-nexus.xml") do
  source "logback-nexus.xml.erb"
  owner  node[:nexus][:user]
  group  node[:nexus][:group]
  mode "0664"
  variables(
    :logs_to_keep => node[:nexus][:logs][:logs_to_keep]
  )
  only_if { Chef::Nexus.nexus_available?(node) }
end
