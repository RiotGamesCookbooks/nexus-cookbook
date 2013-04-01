#
# Cookbook Name:: nexus
# Provider:: logging
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
  @current_resource = Chef::Resource::NexusLogging.new(new_resource.name)

  run_context.include_recipe "nexus::cli"
  Chef::Nexus.ensure_nexus_available(node)

  @current_resource
end

action :set_level do
  
  unless same_logging_level?

    Chef::Nexus.nexus(node).set_logger_level(new_resource.level)
    new_resource.updated_by_last_action(true)
  end
end

private
  
  def same_logging_level?
    require 'json'
    logging_info = JSON.parse(Chef::Nexus.nexus(node).get_logging_info)
    logging_info["data"]["rootLoggerLevel"] == new_resource.level
  end
