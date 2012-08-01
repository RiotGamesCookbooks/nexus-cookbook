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

template "#{node[:nexus][:home]}/conf/nexus.properties" do
  source "nexus.properties.erb"
  owner node[:nexus][:user]
  group node[:nexus][:group]
end

template "/etc/init.d/#{node[:nexus][:name]}" do
  source "nexus.init.d.erb"
  owner "root"
  group "root"
  mode "0775"
  variables(
    :platform => platform
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

template "#{node[:nginx][:dir]}/sites-available/nexus_proxy.conf" do
  source "nexus_proxy.nginx.conf.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :ssl_certificate => "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.pem",
    :options => node[:nexus][:nginx][:options]
  )
end

install_plugin "foo"

#available_plugins = Dir.entries("#{node[:nexus][:home]}/nexus/WEB-INF/optional-plugins")
#node[:nexus][:plugins].each do |plugin|
#  matched_plugin = available_plugins.find{|plugin_dir| plugin_dir.match(plugin)}
  
#  link "#{node[:nexus][:home]}/nexus/WEB-INF/optional-plugins/#{matched_plugin}" do
#    to "#{node[:nexus][:home]}/nexus/WEB-INF/plugin-repository/#{matched_plugin}"
#  end
#end

nginx_site 'nexus_proxy.conf'

service node[:nexus][:name] do
  supports :status => true, :console => true, :start => true, :stop => true, :restart => true, :dump => true
  action [:enable, :start]
end
