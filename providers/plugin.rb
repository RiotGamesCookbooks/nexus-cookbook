#
# Cookbook Name:: nexus
# Provider:: plugin
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
  @current_resource = Chef::Resource::NexusPlugin.new(new_resource.name)
end

action :install do
  unless ::File.exists?("#{node[:nexus][:current_path]}/nexus/WEB-INF/plugin-repository/#{@current_resource.name}")
    plugin = new_resource.name
    matched_plugin = get_plugin(plugin)
    if matched_plugin.nil? || matched_plugin.empty?
      log "Plugin #{plugin} did not match any optional-plugins for your Nexus installation."
    else
      log "Adding symlink #{node[:nexus][:current_path]}/nexus/WEB-INF/plugin-repository/#{matched_plugin} to #{node[:nexus][:home]}/nexus/WEB-INF/optional-plugins/#{matched_plugin}"
      link "#{node[:nexus][:current_path]}/nexus/WEB-INF/plugin-repository/#{matched_plugin}" do
        to "#{node[:nexus][:current_path]}/nexus/WEB-INF/optional-plugins/#{matched_plugin}"
      end
    end
    new_resource.updated_by_last_action(true)
  end
end

private
def available_plugins
  Dir.entries("#{node[:nexus][:current_path]}/nexus/WEB-INF/optional-plugins")
end

def get_plugin(plugin)
  available_plugins.find{|plugin_dir| plugin_dir.match(plugin)}
end