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

def load_current_resource
  @current_resource = Chef::Resource::NexusRepository.new(new_resource.name)
end

action :create do
  install_nexus_cli

  unless repository_exists?(@current_resource.name)
    nexus.create_repository(new_resource.name)
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  install_nexus_cli

  if repository_exists?(@current_resource.name)
    nexus.delete_repository(new_resource.name)
    new_resource.updated_by_last_action(true)
  end
end

private
  
  def install_nexus_cli
    package "libxml2-devel" do
      action :install
    end.run_action(:install)

    package "libxslt-devel" do
      action :install
    end.run_action(:install)
    
    chef_gem "nexus_cli" do
      version "0.6.0"
    end
  end

  def nexus_cli_credentials
    data_bag_item = Chef::EncryptedDataBagItem.load('nexus', 'credentials')
    credentials = data_bag_item["default_admin"]
    {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository]}.merge credentials
  end

  def nexus
    require 'nexus_cli'
    @nexus ||= NexusCli::Factory.create(nexus_cli_credentials)
  end

  def repository_exists?(name)
    begin
      nexus.get_repository_info(name)
      true
    rescue NexusCli::RepositoryNotFoundException => e
      return false
    end
  end