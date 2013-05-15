#
# Cookbook Name:: nexus
# Recipe:: _common_system
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
user_home = ::File.join(node[:nexus][:base_dir], node[:nexus][:user])

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
