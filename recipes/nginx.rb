#
# Cookbook Name:: nexus
# Recipe:: nginx
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
include_recipe "nginx"

directory "#{node[:nginx][:dir]}/shared/certificates" do
  owner     "root"
  group     "root"
  mode      "700"
  recursive true
end

data_bag_item = Chef::Nexus.get_ssl_certificates_data_bag(node)

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
  log "Could not find ssl_certificate data bag, using default certificate." do
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
    :listen_port     => node[:nexus][:ssl][:port],
    :server_name     => node[:nexus][:nginx_proxy][:server_name],
    :fqdn            => node[:fqdn],
    :server_options  => node[:nexus][:nginx][:server][:options],
    :proxy_options   => node[:nexus][:nginx][:proxy][:options]
  )
end

nginx_site 'nexus_proxy.conf'