#
# Cookbook Name:: nexus
# Recipe:: app
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
include_recipe "nexus::_common_system"
include_recipe "java"

artifact_deploy node[:nexus][:name] do
  version           node[:nexus][:version]
  artifact_location node[:nexus][:url]
  artifact_checksum node[:nexus][:checksum]
  deploy_to         node[:nexus][:home]
  owner             node[:nexus][:user]
  group             node[:nexus][:group]
  symlinks({
    "log" => "#{node[:nexus][:bundle_name]}/logs"
  })

  before_extract Proc.new {
    service "nexus" do
      action :stop
      only_if do File.exist?("/etc/init.d/nexus") end
    end
  }

  before_symlink Proc.new {
    nexus_home = ::File.join(release_path, node[:nexus][:bundle_name])

    directory "#{nexus_home}/logs" do
      recursive true
      action :delete
    end
  }

  configure Proc.new {

    nexus_home = ::File.join(release_path, node[:nexus][:bundle_name])
    conf_dir   = ::File.join(nexus_home, "conf")
    bin_dir    = ::File.join(nexus_home, "bin")

    [ node[:nexus][:pid_dir], node[:nexus][:work_dir] ].each do |dir|
      directory dir do
        owner     node[:nexus][:user]
        group     node[:nexus][:user]
        recursive true
      end
    end

    template "#{bin_dir}/#{node[:nexus][:name]}" do
      source "nexus.erb"
      owner  node[:nexus][:user]
      group  node[:nexus][:group]
      mode   "0775"
      variables(
        :nexus_user => node[:nexus][:user],
        :nexus_pid  => node[:nexus][:pid_dir]
      )
    end
    
    template "#{conf_dir}/nexus.properties" do
      source "nexus.properties.erb"
      owner  node[:nexus][:user]
      group  node[:nexus][:group]
      mode   "0775"
      variables(
        :nexus_port         => node[:nexus][:port],
        :nexus_host         => node[:nexus][:host],
        :nexus_context_path => node[:nexus][:context_path],
        :work_dir           => node[:nexus][:work_dir],
        :fqdn               => node[:fqdn]
      )
    end

    template "#{conf_dir}/jetty.xml" do
      source "jetty.xml.erb"
      owner  node[:nexus][:user]
      group  node[:nexus][:group]
      mode   "0775"
      variables(
        :loopback  => node[:nexus][:app_server][:jetty][:loopback]
      )
    end

    link "/etc/init.d/nexus" do
      to "#{bin_dir}/#{node[:nexus][:name]}"
    end
  }
end

service "nexus" do
  action   [:enable, :start]
end
