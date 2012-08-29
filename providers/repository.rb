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

def load_current_resource
  @current_resource = Chef::Resource::NexusRepository.new(new_resource.name)

  run_context.include_recipe "nexus::cli"

  @parsed_id = new_resource.name.gsub(" ", "_").downcase
  @current_resource
end

action :create do
  unless repository_exists?(@current_resource.name)
    validate_proxy
    Chef::Nexus.nexus(node).create_repository(new_resource.name, new_resource.type == "proxy", new_resource.url)
    if new_resource.publisher
      set_publisher
    end
    if new_resource.subscriber
      set_subscriber
    end
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if repository_exists?(@current_resource.name)
    Chef::Nexus.nexus(node).delete_repository(new_resource.name)
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

    if new_resource.subscriber
      set_subscriber
    elsif new_resource.subscriber == false
      unset_subscriber
    end
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

  def validate_proxy
    Chef::Application.fatal!("If this repository is a Proxy repository, you also need to provide a url.") if new_resource.type == "proxy" && new_resource.url.nil?
    Chef::Application.fatal!("You need to provide a valid url.") if new_resource.type == "proxy" && (new_resource.url =~ URI::ABS_URI).nil?
  end
