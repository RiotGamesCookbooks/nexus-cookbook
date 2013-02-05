#
# Cookbook Name:: nexus
# Provider:: group_repository
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

def load_current_resource
  @current_resource = Chef::Resource::NexusGroupRepository.new(new_resource.name)

  run_context.include_recipe "nexus::cli"
  Chef::Nexus.ensure_nexus_available(node)

  @parsed_id         = Chef::Nexus.parse_identifier(new_resource.name)
  @parsed_repository = Chef::Nexus.parse_identifier(new_resource.repository) unless new_resource.repository.nil?

  @current_resource.repository @parsed_repository

  @current_resource
end

action :create do
  unless group_repository_exists?(@current_resource.name)
    Chef::Nexus.nexus(node).create_group_repository(new_resource.name, nil, nil)
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if group_repository_exists?(@current_resource.name)
    Chef::Nexus.nexus(node).delete_group_repository(@parsed_id)
    new_resource.updated_by_last_action(true)
  end
end

action :add_to do
  unless repository_in_group?(@current_resource.name, @current_resource.repository)
    Chef::Nexus.nexus(node).add_to_group_repository(@parsed_id, @parsed_repository)
    new_resource.updated_by_last_action(true)
  end
end

action :remove_from do
  if repository_in_group?(@current_resource.name, @current_resource.repository)
    Chef::Nexus.nexus(node).remove_from_group_repository(@parsed_id, @parsed_repository)
    new_resource.updated_by_last_action(true)
  end
end

private
  
  def group_repository_exists?(name)
    begin
      Chef::Nexus.nexus(node).get_group_repository(name)
      true
    rescue NexusCli::RepositoryNotFoundException => e
      return false
    end
  end

  def repository_in_group?(repository_name, repository_to_check)
    Chef::Nexus.nexus(node).repository_in_group?(repository_name, repository_to_check)
  end
