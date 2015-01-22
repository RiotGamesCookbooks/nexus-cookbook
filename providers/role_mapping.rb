#
# Cookbook Name:: nexus
# Provider:: role_mapping
#
# Author:: Leo Simons (<lsimons@schubergphilis.com>)
# Copyright 2013, Riot Games
# Copyright 2014, Schuberg Philis
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
  @current_resource = Chef::Resource::NexusRoleMapping.new(new_resource.name)

  run_context.include_recipe "nexus::cli"
  Chef::Nexus.ensure_nexus_available(node)

  @parsed_id = new_resource.name

  @current_resource
end

action :create do
  unless role_mapping_exists?(@current_resource.name)
    Chef::Nexus.nexus(node).create_role_mapping(new_resource.name, new_resource.roles, new_resource.privileges)
    new_resource.updated_by_last_action(true)
    Chef::Log.info "Created nexus role mapping #{new_resource.name}"
  end
end

action :delete do
  if role_mapping_exists?(@current_resource.name)
    Chef::Nexus.nexus(node).delete_role_mapping(@parsed_id)
    new_resource.updated_by_last_action(true)
    Chef::Log.info "Deleted nexus role mapping #{new_resource.name}"
  end
end

action :update do
  if role_mapping_exists?(@current_resource.name)
    Chef::Nexus.nexus(node).update_role_mapping(@parsed_id, new_resource.roles, new_resource.privileges)
    new_resource.updated_by_last_action(true)
    Chef::Log.info "Updated nexus role mapping #{new_resource.name}"
  end
end

private

def role_mapping_exists?(name)
  begin
    Chef::Nexus.nexus(node).get_role_mapping_info(name)
    true
  rescue NexusCli::RoleMappingNotFoundException => e
    return false
  end
end
