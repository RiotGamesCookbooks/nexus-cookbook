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
end

action :update do
  install_nexus_cli

  unless path_value_equals?(@current_resource.value)
    ruby_block "update the json and upload it" do
      block do
        update_nexus_settings_json
        upload_nexus_settings_json
      end
    end
    new_resource.updated_by_last_action(true)
  end

end

private
def install_nexus_cli
  chef_gem "neuxs_cli" do
    version "0.4.0"
  end
end

def path_value_equals?(value)
  ruby_block "check whether the current settings are already equal to value" do
    block do
      paths = @current_resource.path.split("/")
      json = get_nexus_settings_json
      paths.each do |path|
        return false unless json.kind_of? Hash
        json = json[path]
      end
      json == value
    end
  end
end

def get_nexus_settings_json
  ruby_block "get the json from nexus" do
    block do
      require 'nexus_cli'
      nexus = NexusCli::Factory.create(nexus_cli_credentials)
      nexus.get_global_settings
      JSON.parse(File.read(File.join(File.expand_path("."), "global_settings.json")))
    end
  end
end

def update_nexus_settings_json
  ruby_block "update the settings json" do
    block do
      json = JSON.parse(File.read(File.join(File.expand_path("."), "global_settings.json")))
      paths = @current_resource.path.split("/")
      json_edit = paths.inject("json") do |string, path|
        string << "[\"#{path}\"]"
      end
      File.open(File.join(File.expand_path("."), "global_settings.json"), "w+") do |opened|
        json_edit << " = @current_resource.value"
        eval json_edit
        opened.write(JSON.pretty_generate(json))
      end
    end
  end
end

def upload_nexus_settings_json
  ruby_block "upload the json to nexus" do
    block do
      nexus = NexusCli::Factory.create(nexus_cli_credentials)
      nexus.upload_global_settings
    end
  end
end

def nexus_cli_credentials
  {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository], "username" => node[:nexus][:cli][:username], "password" => node[:nexus][:cli][:password]}
end