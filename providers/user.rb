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

  run_context.include_recipe "nexus::cli"

  @current_resource
end

action :create do
  unless user_exists?(@current_resource.username)
    create_user
    new_resource.updated_by_last_action(true)
  end
end

action :update do
  if user_exists?(@current_resource.username)
    update_user
    new_resource.updated_by_last_action(true)
  end
end

action :delete do
  if user_exists?(@current_resource.username)
    delete_user
    new_resource.updated_by_last_action(true)
  end
end

action :change_password do
  unless password_equals?(@current_resource.password)
    change_password
    new_resource.updated_by_last_action(true)
  end
end

private

  def user_exists?(username)
    begin
      nexus.get_user(username)
      true
    rescue NexusCli::UserNotFoundException => e
      return false
    end
  end

  def password_equals?(password)
    data_bag_item = Chef::Nexus.get_credentials_data_bag
    data_bag_item["default_admin"]["password"] == password
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

  def change_password
    validate_change_password
    if nexus.change_password(get_password_params) && nexus_cli_credentials["username"] == new_resource.username
      update_nexus_cli_credentials
    end
  end

  def validate_create_user
    Chef::Application.fatal!("nexus_user create requires an email address.", 1) if new_resource.email.nil?
    Chef::Application.fatal!("nexus_user create requires a enabled.", 1) if new_resource.enabled.nil?
    Chef::Application.fatal!("nexus_user create requires at least one role.", 1) if new_resource.roles.nil? || new_resource.roles.empty?
  end

  def validate_change_password
    Chef::Application.fatal!("nexus_user change_password requires your old password") if new_resource.old_password.nil?
    Chef::Application.fatal!("nexus_user change_password requires a new password") if new_resource.password.nil?
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

  def get_password_params
    params = {:userId => new_resource.username}
    params[:oldPassword] = new_resource.old_password
    params[:newPassword] = new_resource.password
    params
  end

  def nexus
    require 'nexus_cli'
    @nexus = NexusCli::Factory.create(nexus_cli_credentials)
  end

  def nexus_cli_credentials
    data_bag_item = Chef::Nexus.get_credentials_data_bag
    credentials = data_bag_item["default_admin"]
    {"url" => node[:nexus][:cli][:url], "repository" => node[:nexus][:cli][:repository]}.merge credentials
  end

  def update_nexus_cli_credentials
    data_bag_item = Chef::Nexus.get_credentials_data_bag
    data_bag_hash = data_bag_item.to_hash
    data_bag_hash["default_admin"]["password"] = new_resource.password
    data_bag_item = Chef::EncryptedDataBagItem.encrypt_data_bag_item(data_bag_hash, Chef::EncryptedDataBagItem.load_secret)
  
    if Chef::Config[:solo]
      ::File.open(::File.join(Chef::Config[:data_bag_path], "nexus/credentials.json"), "w") do |opened|
        opened.write(data_bag_item.to_json)
      end
    else
      Chef::DataBagItem.from_hash(data_bag_item).save
    end
  end
