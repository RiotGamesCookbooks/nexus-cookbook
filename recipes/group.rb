#
# Cookbook Name:: nexus
# Recipe:: group
#
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
data_bag_for_node = Chef::Nexus.get_group_repositories(node)

data_bag_for_node[:repositories].each do |repository|
  
  nexus_group_repository repository[:name]

  repository[:add].each do |repository_to_add|
    nexus_group_repository repository[:name] do
      action     :add_to
      repository repository_to_add
    end
  end

  if repository[:remove]
    repository[:remove].each do |repository_to_remove|
      nexus_group_repository repository[:name] do
        action     :remove_from
        repository repository_to_remove
      end
    end
  end
end