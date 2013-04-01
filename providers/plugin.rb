#
# Cookbook Name:: nexus
# Provider:: plugin
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
  @current_resource = Chef::Resource::NexusPlugin.new(new_resource.name)
end

action :install do
  plugin_name = get_plugin(new_resource.name)
  if plugin_name.nil? || plugin_name.empty?
    Chef::Application.fatal! "Could not find a plugin that matches #{new_resource.name} in #{new_resource.plugin_path}."
  end

  unless ::File.exists?("#{nexus_plugins_path}/#{plugin_name}")
    log "Symlinking #{new_resource.plugin_path}/#{plugin_name} to #{nexus_plugins_path}/#{plugin_name}"
    link "#{nexus_plugins_path}/#{plugin_name}" do
      to "#{new_resource.plugin_path}/#{plugin_name}"
    end
    new_resource.updated_by_last_action(true)
  end
end

private

  # @return [String] the joined path of the Nexus installation's plugin-repository
  def nexus_plugins_path
    ::File.join(new_resource.nexus_path, node[:nexus][:bundle_name], "/nexus/WEB-INF/plugin-repository")
  end

  # Searches the plugin_path for a plugin that matches the given
  # plugin parameter.
  # 
  # @param  plugin [String] the name of the plugin to find
  # 
  # @return [String] the full name of the plugin found
  def get_plugin(plugin)
    available_plugins = Dir.entries(new_resource.plugin_path)
    available_plugins.find{|plugin_dir| plugin_dir.match(plugin)}
  end
