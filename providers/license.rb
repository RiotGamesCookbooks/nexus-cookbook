#
# Cookbook Name:: nexus
# Provider:: license
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
  @current_resource = Chef::Resource::NexusLicense.new(new_resource.name)

  run_context.include_recipe "nexus::cli"
  Chef::Application.fatal!("Could not connect to Nexus. Please ensure Nexus is running.") unless Chef::Nexus.nexus_available?(node)
  
  @current_resource
end

action :install do

  unless licensed? && running_nexus_pro?

    require 'base64'
    data_bag_item = Chef::Nexus.get_license_data_bag
    license_data = Base64.decode64(data_bag_item["file"])
    Chef::Nexus.nexus(node).install_license_bytes(license_data)
    new_resource.updated_by_last_action(true)
  end
end

private
  
  def licensed?
    require 'json'
    json = JSON.parse(Chef::Nexus.nexus(node).get_license_info)
    json["data"]["licenseType"] != "Not licensed"
  end

  def running_nexus_pro?
    Chef::Nexus.nexus(node).running_nexus_pro?
  end