#
# Cookbook Name:: nexus
# Provider:: proxy
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
  @current_resource = Chef::Resource::NexusProxy.new(new_resource.name)
  @current_resource.id new_resource.id
  @current_resource.host new_resource.host
  @current_resource.port new_resource.port
  @current_resource.certificate new_resource.certificate
  @@current_resource.description new_resource.description
end

action :enable do
  install_nexus_cli

  unless smart_proxy_enabled?
    enable_smart_proxy
    new_resource.updated_by_last_action(true)
  end
end

action :disable do
  install_nexus_cli

  if smart_proxy_enabled?
    disable_smart_proxy
    new_resource.updated_by_last_action(true)
  end
end

action :add_trusted_key do

  unless certificate_exists?
    nexus.add_trusted_key(new_resource.certificate, new_resource.description, false)
    new_resource.updated_by_last_action(true)
  end
end

action :delete_trusted_key do

  if trusted_key_exists?
    nexus.delete_trusted_key(new_resource.id)
    new_resource.updated_by_last_action(true)
  end
end

private
  
  def install_nexus_cli
    package "libxml2-devel" do
      action :install
    end.run_action(:install)

    package "libxslt-devel" do
      action :install
    end.run_action(:install)
    
    chef_gem "nexus_cli" do
      version "0.7.0"
    end
  end

  def smart_proxy_enabled?
    require 'json'
    json = JSON.parse(nexus.get_smart_proxy_settings)
    json["data"]["enabled"]
  end

  def certificate_exists?
    require 'json'
    json = JSON.parse(nexus.get_trusted_keys)
    trusted_keys = json["data"]
    trusted_keys.each do |trusted_key|
      if new_resource.certificate == trusted_key["certificate"]["pem"]
        return true
      end
    end
    false    
  end

  def trusted_key_exists?
    require 'json'
    json = JSON.parse(nexus.get_trusted_keys)
    trusted_keys = json["data"]
    trusted_keys.each do |trusted_key|
      if new_resource.id == trusted_key["id"]
        return true
      end
    end
    false
  end

  def enable_smart_proxy
    nexus.enable_smart_proxy(false, new_resource.host, new_resource.port)
  end

  def disable_smart_proxy
    nexus.enable_smart_proxy(true)
  end

  def nexus_cli_credentials
    data_bag_item = Chef::EncryptedDataBagItem.load('nexus', 'credentials')
    credentials = data_bag_item["default_admin"]
    {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository]}.merge credentials
  end

  def nexus
    require 'nexus_cli'
    @nexus ||= NexusCli::Factory.create(nexus_cli_credentials)
  end
