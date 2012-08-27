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
end

action :install do
  install_nexus_cli

  if licensed?

    require 'base64'
    data_bag_item = Chef::EncryptedDataBagItem.load('nexus', 'license')
    license_data = Base64.decode64(data_bag_item["file"])
    nexus.install_license_bytes(license_data)
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

  def nexus_cli_credentials
    data_bag_item = Chef::EncryptedDataBagItem.load('nexus', 'credentials')
    credentials = data_bag_item["default_admin"]
    {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository]}.merge credentials
  end

  def nexus
    require 'nexus_cli'
    @nexus ||= NexusCli::Factory.create(nexus_cli_credentials)
  end

  def licensed?
    require 'json'
    json = JSON.parse(nexus.get_license_info)
    log(json) { level :debug }
    log(json["data"]["licenseType"] == "Not licensed")
    json["data"]["licenseType"] != "Not licensed"
  end