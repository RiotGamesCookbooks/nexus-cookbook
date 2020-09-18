#
# Cookbook Name:: nexus
# Provider:: settings
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
  @current_resource = Chef::Resource::resource_for_node(:nexus_settings, node).new(new_resource.name)
  @current_resource.value new_resource.value

  run_context.include_recipe "nexus::cli"
  Chef::Nexus.ensure_nexus_available(node)
  
  @current_resource
end

action :update do
  unless path_value_equals?(@current_resource.value)
    update_nexus_settings_json
    new_resource.updated_by_last_action(true)
  end
end

private

  def path_value_equals?(value)
    require 'jsonpath'
    json = JSON.parse(get_nexus_settings_json)
    path_value = JsonPath.new("$..#{new_resource.path}").on(json).first
    path_value == value
  end

  def get_nexus_settings_json
    Chef::Nexus.nexus(node).get_global_settings_json
  end

  def update_nexus_settings_json
    require 'json'
    hashed_settings = JSON.parse(get_nexus_settings_json)
    *path_elements, setting_to_update = new_resource.path.split(".")
    path_elements.inject(hashed_settings, :fetch)[setting_to_update] = new_resource.value
    Chef::Nexus.nexus(node).upload_global_settings(JSON.dump(hashed_settings))
  end
