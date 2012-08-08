#
# Cookbook Name:: nexus
# Recipe:: default
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
include_recipe "ark"
include_recipe "java"
include_recipe "nginx::source"
include_recipe "bluepill"

user_home = "/#{node[:nexus][:user]}"
path_file_name = "#{user_home}/nexus-#{node[:nexus][:version]}-bundle.tar.gz"

platform = ""
case node[:platform]
when "centos", "redhat", "debian", "ubuntu", "amazon", "scientific"
  platform = "linux-x86-64"
end

group node[:nexus][:group] do
  system true
end

user node[:nexus][:group] do
  gid node[:nexus][:group]
  shell "/bin/bash"
  home user_home
  system true
end

directory user_home do
  owner node[:nexus][:user]
  group node[:nexus][:group]
  mode "0755"
  action :create
end

ark node[:nexus][:name] do
  url node[:nexus][:url]
  version node[:nexus][:version]
  owner node[:nexus][:user]
  group node[:nexus][:group]
  action :install
end

template "#{node[:nexus][:conf_dir]}/nexus.properties" do
  source "nexus.properties.erb"
  owner node[:nexus][:user]
  group node[:nexus][:group]
  variables(
    :nexus_port => "#{node[:nexus][:port]}",
    :nexus_host => "#{node[:nexus][:host]}",
    :nexus_path => "#{node[:nexus][:path]}",
    :fqdn => node[:fqdn]
  )
end

template "#{node[:nexus][:bin_dir]}/#{node[:nexus][:name]}" do
  source "nexus.erb"
  owner "root"
  group "root"
  mode "0775"
  variables(
    :platform => platform,
    :nexus_home => "#{node[:nexus][:home]}",
    :nexus_user => "#{node[:nexus][:user]}"
  )
end

directory "#{node[:nginx][:dir]}/shared/certificates" do
  owner "root"
  group "root"
  mode "700"
  recursive true
end

cookbook_file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.pem" do
  source "self_signed_cert.pem"
  mode "077"
  action :create_if_missing
end

cookbook_file "#{node[:nexus][:conf_dir]}/jetty.xml" do
  source "jetty.xml"
  mode "0775"
  owner node[:nexus][:user]
  group node[:nexus][:group] 
end

template "#{node[:nginx][:dir]}/sites-available/nexus_proxy.conf" do
  source "nexus_proxy.nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :ssl_certificate => "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.pem",
    :listen_port => node[:nexus][:nginx_proxy][:listen_port],
    :server_name => node[:nexus][:nginx_proxy][:server_name],
    :fqdn => node[:fqdn],
    :options => node[:nexus][:nginx][:options]
  )
end

node[:nexus][:plugins].each do |plugin| 
  nexus_plugin plugin
end
nginx_site 'nexus_proxy.conf'

template "#{node[:bluepill][:conf_dir]}/nexus.pill" do
  source "nexus.pill.erb"
  mode 0644
  variables(
    :pid_dir => node[:bluepill][:pid_dir],
    :bin_dir => node[:nexus][:bin_dir],
    :home_dir => node[:nexus][:home],
    :name => node[:nexus][:name]
  )
end

bluepill_service "nexus" do
  action [:enable, :load, :start]
end