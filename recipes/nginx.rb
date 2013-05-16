#
# Cookbook Name:: nexus
# Recipe:: _nginx
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

template "#{node[:nginx][:dir]}/sites-available/nexus_proxy.conf" do
  source "nexus_proxy.nginx.conf.erb"
  owner  "root"
  group  "root"
  mode   "0644"
  variables(
    :ssl_certificate => "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.crt",
    :ssl_key         => "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.key",
    :listen_port     => node[:nexus][:app_server_proxy][:ssl][:port],
    :server_name     => node[:nexus][:app_server_proxy][:nginx][:server_name],
    :fqdn            => node[:fqdn],
    :server_options  => node[:nexus][:app_server_proxy][:nginx][:server][:options],
    :proxy_options   => node[:nexus][:app_server_proxy][:nginx][:proxy][:options]
  )
end

nginx_site 'nexus_proxy.conf'
