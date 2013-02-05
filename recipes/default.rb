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
#
include_recipe "java"
include_recipe "nginx"
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

directory "#{node[:nginx][:dir]}/shared/certificates" do
  owner     "root"
  group     "root"
  mode      "700"
  recursive true
end

# TODO: Come back to this and fix it for Chef-client runs
data_bag_item = Chef::Nexus.get_ssl_certificate_data_bag(node)

if data_bag_item

  log "Using ssl_certificate data bag entry for #{node[:nexus][:ssl_certificate][:key]}" do
    level :info
  end

  data_bag_item = data_bag_item[node[:nexus][:ssl_certificate][:key]]
  certificate = Chef::Nexus.get_ssl_certificate_crt(data_bag_item)
  key = Chef::Nexus.get_ssl_certificate_key(data_bag_item)

  file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.crt" do
    content certificate
    mode    "077"
    action :create
  end

  file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.key" do
    content key
    mode    "077"
    action  :create
  end
else
  log "Could not find nexus_ssl_certificate data bag, using default certificate." do
    level :warn
  end

  cookbook_file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.crt" do
    source "self_signed_cert.crt"
    mode   "077"
    action :create
  end

  cookbook_file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.key" do
    source "self_signed_key.key"
    mode   "077"
    action :create
  end
end

template "#{node[:nginx][:dir]}/sites-available/nexus_proxy.conf" do
  source "nexus_proxy.nginx.conf.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  variables(
    :ssl_certificate => "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.crt",
    :ssl_key         => "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.key",
    :listen_port     => node[:nexus][:nginx_proxy][:listen_port],
    :server_name     => node[:nexus][:nginx_proxy][:server_name],
    :fqdn            => node[:fqdn],
    :server_options  => node[:nexus][:nginx][:server][:options],
    :proxy_options   => node[:nexus][:nginx][:proxy][:options]
  )
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

# Sonatype recommends not using NFS at all, and if you have to use it
# you should symlink the indexer and timeline directories to a non-NFS
# drive. Commenting this out for now until we run into a problem with NFS.

#link "#{node[:nexus][:work_dir]}/indexer" do
#  to node[:nexus][:mount][:nfs][:non_mount_dir][:indexer]
#  only_if {node[:nexus][:mount][:nfs][:enable]}
#end

#link "#{node[:nexus][:work_dir]}/timeline" do
#  to node[:nexus][:mount][:nfs][:non_mount_dir][:timeline]
#  only_if {node[:nexus][:mount][:nfs][:enable]}
#end

nginx_site 'nexus_proxy.conf'

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
        :loopback => node[:nexus][:jetty][:loopback]
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
  notifies :restart, "service[nginx]", :immediately
end

nexus_settings "baseUrl" do
  value "https://#{node[:nexus][:nginx_proxy][:server_name]}:#{node[:nexus][:nginx_proxy][:listen_port]}/nexus"
end

nexus_settings "forceBaseUrl" do
  value true
end

data_bag_item = Chef::Nexus.get_credentials(node)
default_credentials = data_bag_item["default_admin"]
updated_credentials = data_bag_item["updated_admin"]

nexus_user "admin" do
  action       :change_password
  old_password default_credentials["password"]
  password     updated_credentials["password"]
end

ruby_block "set flag that default admin credentials were changed" do
  block do
    node.set[:nexus][:cli][:default_admin_credentials_updated] = true
  end
end