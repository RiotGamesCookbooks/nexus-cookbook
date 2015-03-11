#
# Cookbook Name:: nexus
# Provider:: task
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
  @current_resource = Chef::Resource::NexusTask.new(new_resource.name)

  run_context.include_recipe "nexus::cli"
  Chef::Nexus.ensure_nexus_available(node)

  @current_resource
end

action :create do
  unless task_exists?(@current_resource.name)
    nexus = Chef::Nexus.nexus(node)
    method_sym = "create_#{new_resource.type.to_s}_task".to_sym
    args = [
        new_resource.name,
        new_resource.schedule,
        new_resource.enabled,
        new_resource.start_date,
        new_resource.recurring_time,
        new_resource.repository_id
    ]
    case new_resource.type
      when :empty_trash
        args += [new_resource.older_than_days]
      when :download_nuget_feed
        args += [
            new_resource.clear_cache,
            new_resource.all_versions,
            new_resource.retries,
        ]
      when :snapshot_remover
        args += [
            new_resource.min_snapshots,
            new_resource.remove_older,
            new_resource.remove_if_release,
            new_resource.grace_after_release,
            new_resource.delete_immediately,
        ]
      else
        # ignore
    end
    nexus.send(method_sym, *args)
    new_resource.updated_by_last_action(true)
    Chef::Log.info "Created nexus task #{new_resource.name}"
  end
end

action :delete do
  if task_exists?(@current_resource.name)
    Chef::Nexus.nexus(node).delete_task(@current_resource.name)
    new_resource.updated_by_last_action(true)
    Chef::Log.info "Deleted nexus task #{new_resource.name}"
  end
end

private

def task_exists?(name)
  task_response = Chef::Nexus.nexus(node).get_tasks
  task_response.include? "<name>#{name}</name>"
end
