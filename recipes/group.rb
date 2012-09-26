#
# Cookbook Name:: nexus
# Recipe:: group
#
# Copyright 2012, Riot Games
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
node[:nexus][:repository][:group].each do |repository|
  
  nexus_repository repository[:name] do
  	action :create
  	type "group"
  end

  repository[:add].each do |repository_to_add|
    nexus_repository repository[:name] do
      action            :add_to
      type              "group"
      repository_to_add repository_to_add
    end
  end

  repository[:remove].each do |repository_to_remove|
    nexus_repository repository[:name] do
      action               :remove_from
      type                 "group"
      repository_to_remove repository_to_remove
    end
  end

end