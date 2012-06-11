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

app = {
  'name' => 'nexus',
  'version' => node['nexus']['version'],
  'user' => node['nexus']['user'],
  'group' => node['nexus']['group'],
  'url' => node['nexus']['url']
}

user_home = "/var/lib/#{app['user']}"
install_dir = "/usr/local/#{app['name']}"
conf_dir = "#{install_dir}/conf"
plugin_repo_path = "#{user_home}/plugin-repository"

group app['group'] do
  system true
end

user app['user'] do
  gid app['group']
  shell "/bin/bash"
  home user_home
  system true
end

directory user_home do
  owner app['user']
  group app['group']
  mode "0755"
  action :create
end

ark app['name'] do
  url app['url']
  version app['version']
  owner app['user']
  group app['group']
  action :install
end

template "#{conf_dir}/plexus.properties" do
  source "plexus.properties.erb"
  owner app['user']
  group app['group']
end

template "/etc/init.d/#{app['name']}" do
  source "nexus.erb"
  owner "root"
  group "root"
  mode "0775"
end

directory plugin_repo_path do
  owner app['user']
  group app['group']
  mode "0775"
  action :create
end

service app['name'] do
   action [:enable, :start]
end
