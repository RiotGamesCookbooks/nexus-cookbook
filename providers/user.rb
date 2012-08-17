#
# Cookbook Name:: nexus
# Provider:: user
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
  @current_resource = Chef::Resource::NexusUser.new(new_resource.username)
  @current_resource.first_name new_resource.first_name
  @current_resource.last_name new_resource.last_name
  @current_resource.email new_resource.email
  @current_resource.enabled new_resource.enabled
  @current_resource.password new_resource.password
  @current_resource.old_password new_resource.old_password
  @current_resource.roles new_resource.roles
end

action :create do
  install_nexus_cli

  unless user_exists?(@current_resource.username)
    create_user
    new_resource.updated_by_last_action(true)
  end
end

action :update do
  install_nexus_cli

  if user_exists?(@current_resource.username)
    update_user
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  install_nexus_cli

  if user_exists?(@current_resource.username)
    delete_user
    new_resource.updated_by_last_action(true)
  end
end

action :change_password do
  install_nexus_cli
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
      version "0.6.0"
    end
  end

  def user_exists?(username)
    begin
      nexus.get_user(username)
      true
    rescue NexusCli::UserNotFoundException => e
      return false
    end
  end

  def create_user
    validate_create_user
    nexus.create_user(get_params)
  end

  def update_user
    nexus.update_user(get_params(true))
  end

  def delete_user
    nexus.delete_user(new_resource.username)
  end

  def validate_create_user
    Chef::Log.fatal("Yo you need to give an email address.") if new_resource.email.nil?
    Chef::Log.fatal("Yo you need to give a status.") if new_resource.enabled.nil?
    Chef::Log.fatal("Yo you need to have at least one role.") if new_resource.roles.nil? || new_resource.roles.empty?
  end

  def get_params(update=false)
    params = {:userId => new_resource.username}
    params[:firstName] = new_resource.first_name
    params[:lastName] = new_resource.last_name
    params[:email] = new_resource.email
    if new_resource.enabled.nil? && update
      params[:status] = nil
    else
      params[:status] = new_resource.enabled == true ? "active" : "disabled"
    end
    params[:password] = new_resource.password
    params[:roles] = new_resource.roles
    params
  end

  def nexus
    require 'nexus_cli'
    @nexus ||= NexusCli::Factory.create(nexus_cli_credentials)
  end

  def nexus_cli_credentials
    data_bag_item = Chef::EncryptedDataBagItem.load('nexus', 'credentials')
    credentials = data_bag_item["default_admin"]
    {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository]}.merge credentials
  end