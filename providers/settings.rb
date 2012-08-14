#
# Cookbook Name:: nexus
# Provider:: settings
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
  @current_resource = Chef::Resource::NexusSettings.new(new_resource.path)
  @current_resource.value new_resource.value
end

action :update do
  install_nexus_cli
  install_jsonpath

  unless path_value_equals?(@current_resource.value)
    update_nexus_settings_json
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
      version "0.5.0"
    end
  end

  def install_jsonpath
    chef_gem "jsonpath"
  end

  def path_value_equals?(value)
    require 'jsonpath'
    json = JSON.parse(get_nexus_settings_json)
    path_value = JsonPath.new("$..#{new_resource.path}").on(json).first
    path_value == value
  end

  def get_nexus_settings_json
    nexus.get_global_settings_json
  end

  def update_nexus_settings_json
    require 'json'
    json = JSON.parse(get_nexus_settings_json)
    edited_json = JsonPath.for(json).gsub("$..#{new_resource.path}") {|value| new_resource.value}.to_hash
    nexus.upload_global_settings(JSON.dump(edited_json))
  end

  def nexus_cli_credentials
    {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository], "username" => node[:nexus][:cli][:username], "password" => node[:nexus][:cli][:password]}
  end

  def global_settings
    ::File.join(::File.expand_path("."), "global_settings.json")
  end

  def nexus
    require 'nexus_cli'
    @nexus ||= NexusCli::Factory.create(nexus_cli_credentials)
  end