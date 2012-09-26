#
# Cookbook Name:: nexus
# Provider:: repository
#
# Author:: Kyle Allan (<kallan@riotgames.com>)
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

attr_reader :parsed_id
attr_reader :parsed_repository_to_add_id
attr_reader :parsed_repository_to_remove_id

def load_current_resource
  @current_resource = Chef::Resource::NexusRepository.new(new_resource.name)

  run_context.include_recipe "nexus::cli"

  @parsed_id                      = new_resource.name.gsub(" ", "_").downcase
  @parsed_repository_to_add_id    = new_resource.repository_to_add.gsub(" ", "_").downcase unless new_resource.repository_to_add.nil?
  @parsed_repository_to_remove_id = new_resource.repository_to_remove.gsub(" ", "_").downcase unless new_resource.repository_to_remove.nil?

  @current_resource.repository_to_add    @parsed_repository_to_add_id
  @current_resource.repository_to_remove @parsed_repository_to_remove_id

  @current_resource
end

action :create do
  case new_resource.type
  when "proxy", "hosted"
    unless repository_exists?(@current_resource.name)
      validate_create_proxy
      Chef::Nexus.nexus(node).create_repository(new_resource.name, true, new_resource.url)
      set_publisher if new_resource.publisher
      set_subscriber if new_resource.subscriber
      new_resource.updated_by_last_action(true)
    end
  when "group"
    unless group_repository_exists?(@current_resource.name)
      Chef::Nexus.nexus(node).create_group_repository(new_resource.name)
      new_resource.updated_by_last_action(true)
    end
  end
end

action :delete do
  if repository_exists?(@current_resource.name) || (new_resource.type == "group" && group_repository_exists?(@current_resource.name))
    case new_resource.type
    when "proxy", "hosted"
      Chef::Nexus.nexus(node).delete_repository(@parsed_id)
    when "group"
      Chef::Nexus.nexus(node).delete_group_repository(@parsed_id)
    end
    new_resource.updated_by_last_action(true)
  end
end

action :update do
  if repository_exists?(@current_resource.name)
    Chef::Application.fatal!("You cannot update a group repository.") if new_resource.type == "group"
    if new_resource.publisher
      set_publisher
    elsif new_resource.publisher == false
      unset_publisher
    end

    if new_resource.subscriber
      set_subscriber
    elsif new_resource.subscriber == false
      unset_subscriber
    end
    new_resource.updated_by_last_action(true)
  end
end

action :add_to do
  validate_add_to
  unless repository_in_group?(@current_resource.name, @current_resource.repository_to_add)
    Chef::Nexus.nexus(node).add_to_group_repository(@parsed_id, @parsed_repository_to_add_id)
    new_resource.updated_by_last_action(true)
  end
end

action :remove_from do
  validate_remove_from
  if repository_in_group?(@current_resource.name, @current_resource.repository_to_remove)
    Chef::Nexus.nexus(node).remove_from_group_repository(@parsed_id, @parsed_repository_to_remove_id)
    new_resource.updated_by_last_action(true)
  end
end

private
  
  def set_publisher
    Chef::Nexus.nexus(node).enable_artifact_publish(@parsed_id)
  end

  def unset_publisher
    Chef::Nexus.nexus(node).disable_artifact_publish(@parsed_id)
  end

  def set_subscriber
    Chef::Nexus.nexus(node).enable_artifact_subscribe(@parsed_id)
  end

  def unset_subscriber
    Chef::Nexus.nexus(node).disable_artifact_subscribe(@parsed_id)
  end

  def repository_exists?(name)
    begin
      Chef::Nexus.nexus(node).get_repository_info(name)
      true
    rescue NexusCli::RepositoryNotFoundException => e
      return false
    end
  end

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

  def validate_create_proxy
    Chef::Application.fatal!("If this repository is a Proxy repository, you also need to provide a url.") if new_resource.type == "proxy" && new_resource.url.nil?
    Chef::Application.fatal!("You need to provide a valid url.") if new_resource.type == "proxy" && (new_resource.url =~ URI::ABS_URI).nil?
  end

  def validate_add_to
    Chef::Application.fatal!("You can only use the :add_to action if type is equal to 'group'.") unless new_resource.type == "group"
    Chef::Application.fatal!("You need to provide the :repository_to_add attribute.") if new_resource.repository_to_add.nil?
  end

  def validate_remove_from
    Chef::Application.fatal!("You can only use the :remove_from action if type is equal to 'group'.") unless new_resource.type == "group"
    Chef::Application.fatal!("You need to provide the :repository_to_remove attribute.") if new_resource.repository_to_remove.nil?
  end