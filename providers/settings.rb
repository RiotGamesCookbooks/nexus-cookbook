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
  @current_resource = Chef::Resource::NexusServer.new(new_resource.url)
end

action :create do
  install_nokogiri

  unless check_server_settings_exist
    ruby_block "create xml and add it to nexus.xml" do
      block do
        nexus_xml
      end
    end
    new_resource.updated_by_last_action(true)
  end

end

private
def install_nokogiri
  chef_gem "nokogiri" do
    action :install
  end

  require 'nokogiri'
end

def nexus_xml
  Nokogiri::XML(::File.new("#{node[:nexus][:work_dir]}/conf/nexus.xml"))
end

def check_server_settings_exist
  nexus_xml.xpath("nexusConfiguration/restApi").empty?
end