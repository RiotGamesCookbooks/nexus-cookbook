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
include_recipe "java"
include_recipe "build-essential"

user_home = "/#{node[:nexus][:user]}"

platform = ""
case node[:platform]
when "centos", "redhat", "debian", "ubuntu", "amazon", "scientific"
  platform = "linux-x86-64"
end

group node[:nexus][:group] do
  system true
end

user node[:nexus][:group] do
  gid    node[:nexus][:group]
  shell  "/bin/bash"
  home   user_home
  system true
end

directory user_home do
  owner  node[:nexus][:user]
  group  node[:nexus][:group]
  mode   "0755"
  action :create
end

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

if node[:nexus][:ssl][:nginx]
  include_recipe "nexus::nginx"
elsif node[:nexus][:ssl][:jetty]
  credentials = Chef::Nexus.get_credentials_data_bag

  jetty_ssl = {
    :keystore_path  => node[:nexus][:ssl][:jetty_keystore_path],
    :password       => credentials[:keystore][:password],
    :key_password   => credentials[:keystore][:key_password],
    :trust_password => credentials[:keystore][:trust_password]
  }

  directory "#{node[:nexus][:ssl][:jetty_keystore_path]}" do
    owner     node[:nexus][:user]
    group     node[:nexus][:group]
    mode      "0755"
    action    :create
    recursive true
  end
end

artifact_deploy node[:nexus][:name] do
  version           node[:nexus][:version]
  artifact_location node[:nexus][:url]
  artifact_checksum node[:nexus][:checksum]
  deploy_to         node[:nexus][:home]
  owner             node[:nexus][:user]
  group             node[:nexus][:group]
  symlinks({
    "log" => "#{node[:nexus][:bundle_name]}/logs"
  })

  before_extract Proc.new {
    service "nexus" do
      action :stop
      provider Chef::Provider::Service::Init
      only_if do File.exist?("/etc/init.d/nexus") end
    end
  }

  before_symlink Proc.new {
    nexus_home = ::File.join(release_path, node[:nexus][:bundle_name])

    directory "#{nexus_home}/logs" do
      recursive true
      action :delete
    end
  }

  configure Proc.new {

    nexus_home = ::File.join(release_path, node[:nexus][:bundle_name])
    conf_dir   = ::File.join(nexus_home, "conf")
    bin_dir    = ::File.join(nexus_home, "bin")

    template "#{bin_dir}/#{node[:nexus][:name]}" do
      source "nexus.erb"
      owner  "root"
      group  "root"
      mode   "0775"
      variables(
        :platform   => platform,
        :nexus_port => node[:nexus][:port],
        :nexus_home => nexus_home,
        :nexus_user => node[:nexus][:user],
        :nexus_pid  => node[:nexus][:pid_dir]
      )
    end
    
    template "#{conf_dir}/nexus.properties" do
      source "nexus.properties.erb"
      owner  node[:nexus][:user]
      group  node[:nexus][:group]
      mode   "0775"
      variables(
        :nexus_port         => node[:nexus][:port],
        :nexus_host         => node[:nexus][:host],
        :nexus_context_path => node[:nexus][:context_path],
        :work_dir           => node[:nexus][:work_dir],
        :fqdn               => node[:fqdn]
      )
    end

    template "#{conf_dir}/jetty.xml" do
      source "jetty.xml.erb"
      owner  node[:nexus][:user]
      group  node[:nexus][:group]
      mode   "0775"
      variables(
        :jetty_ssl => jetty_ssl,
        :loopback  => node[:nexus][:jetty][:loopback]
      )
    end

    node[:nexus][:plugins].each do |plugin| 
      nexus_plugin plugin do
        plugin_path ::File.join(release_path, node[:nexus][:bundle_name], "nexus/WEB-INF/optional-plugins")
        nexus_path  release_path
      end
    end

    link "/etc/init.d/nexus" do
      to "#{bin_dir}/nexus"
    end
  }
end

service "nexus" do
  action   [:enable, :start]
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