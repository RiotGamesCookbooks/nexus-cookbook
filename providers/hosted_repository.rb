#
# Cookbook Name:: nexus
# Provider:: hosted_repository
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
  @current_resource = Chef::Resource::NexusHostedRepository.new(new_resource.name)

  run_context.include_recipe "nexus::cli"
  Chef::Nexus.ensure_nexus_available(node)
  
  @parsed_id = Chef::Nexus.parse_identifier(new_resource.name)

  @current_resource
end

action :create do
  unless repository_exists?(@current_resource.name)
    Chef::Nexus.nexus(node).create_repository(new_resource.name, false, nil, nil, new_resource.policy, nil)
    set_publisher if new_resource.publisher
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if repository_exists?(@current_resource.name)
    Chef::Nexus.nexus(node).delete_repository(@parsed_id)
    new_resource.updated_by_last_action(true)
  end
end

action :update do
  if repository_exists?(@current_resource.name)
    if new_resource.publisher
      set_publisher
    elsif new_resource.publisher == false
      unset_publisher
    end
    new_resource.updated_by_last_action(true)
  end
end

private

  def repository_exists?(name)
    begin
      Chef::Nexus.nexus(node).get_repository_info(name)
      true
    rescue NexusCli::RepositoryNotFoundException => e
      return false
    end
  end

  def set_publisher
    Chef::Nexus.nexus(node).enable_artifact_publish(@parsed_id)
  end

  def unset_publisher
    Chef::Nexus.nexus(node).disable_artifact_publish(@parsed_id)
  end
