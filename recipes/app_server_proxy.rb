#
# Cookbook Name:: nexus
# Recipe:: app_server_proxy
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
include_recipe "nexus::_common_system"
include_recipe "nginx"

directory "#{node[:nginx][:dir]}/shared/certificates" do
  owner     "root"
  group     "root"
  mode      "700"
  recursive true
end

if node[:nexus][:app_server_proxy][:use_self_signed]
  log "Using default (self signed) certificate." do
    level :warn
  end

  cookbook_file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.crt" do
    source "self_signed_cert.crt"
    mode   "600"
    action :create
  end

  cookbook_file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.key" do
    source "self_signed_key.key"
    mode   "600"
    action :create
  end
else
  ssl_files = Chef::Nexus.get_ssl_files_data_bag(node)
  Chef::Application.fatal!("No entry found in nexus_ssl_files data bag for key #{node[:nexus][:app_server_proxy][:ssl][:key]}") unless ssl_files[node[:nexus][:app_server_proxy][:ssl][:key]]

  log "Using nexus_ssl_files data bag entry for #{node[:nexus][:app_server_proxy][:ssl][:key]}" do
    level :info
  end

  entry = ssl_files[node[:nexus][:app_server_proxy][:ssl][:key]]
  certificate = Chef::Nexus.decode(entry[:crt])
  key = Chef::Nexus.decode(entry[:key])

  file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.crt" do
    content certificate
    mode    "600"
    action :create
  end

  file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.key" do
    content key
    mode    "600"
    action  :create
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
    :listen_port     => node[:nexus][:app_server_proxy][:ssl][:port],
    :server_name     => node[:nexus][:app_server_proxy][:server_name],
    :fqdn            => node[:fqdn],
    :server_options  => node[:nexus][:app_server_proxy][:server][:options],
    :proxy_options   => node[:nexus][:app_server_proxy][:proxy][:options],
    :proxy_pass      => node[:nexus][:app_server_proxy][:port]
  )
end

nginx_site 'nexus_proxy.conf'

# Remove nginx default site
nginx_site "default" do
  enable false
end
