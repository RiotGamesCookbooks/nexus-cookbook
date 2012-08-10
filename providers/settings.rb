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
        nexus_xml
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
  paths = @current_resource.path.split("/")
  json = get_nexus_settings_json
  paths.each do |path|
    return false unless json.kind_of? Hash
    json = json[path]
  end
  json == value
end

def get_nexus_settings_json
  ruby_block "get the json from nexus" do
    block do
      require 'nexus_cli'
      NexusCli::Factory.create(nil)
    end
  end
end