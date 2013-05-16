#
# Cookbook Name:: nexus
# Recipe:: _ssl
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
ssl_setup_type = Chef::Nexus.validate_ssl_setup(node[:nexus][:app_server_proxy][:ssl][:setup])
ssl_files = Chef::Nexus.get_ssl_files_data_bag(node)

log "~> HI #{ssl_setup_type.class} and #{ssl_setup_type}"

case ssl_setup_type
when :jetty
  if ssl_files && ssl_files[node[:nexus][:jetty_keystore][:key]]
    ssl_files_for_node = ssl_files[node[:nexus][:app_server_proxy][:ssl][:key]]
    keystore_value = ssl_files_for_node[:keystore]
    
    log "Using nexus_ssl_files data bag entry for #{node[:nexus][:ssl_certificate][:key]}" do
      level :info
    end

    Chef::Application.fatal! "nexus_ssl_files data bag item is missing a 'keystore' key for #{node[:nexus][:jetty_keystore][:key]}" unless keystore_value

    directory node[:nexus][:ssl][:jetty_keystore_path] do
      owner     node[:nexus][:user]
      group     node[:nexus][:group]
      mode      "0755"
      action    :create
      recursive true
    end

    file "#{node[:nexus][:ssl][:jetty_keystore_path]}/keystore" do
      owner   node[:nexus][:user]
      group   node[:nexus][:group]
      mode    "0755"
      content Chef::Nexus.decode(keystore_value)
      action  :create
    end
  end
when :nginx
  directory "#{node[:nginx][:dir]}/shared/certificates" do
    owner     "root"
    group     "root"
    mode      "700"
    recursive true
  end

  if ssl_files && ssl_files[node[:nexus][:app_server_proxy][:ssl][:key]]

    log "Using nexus_ssl_files data bag entry for #{node[:nexus][:app_server_proxy][:ssl][:key]}" do
      level :info
    end

    entry = ssl_files[[:nexus][:app_server_proxy][:ssl][:key]]
    certificate = Chef::Nexus.decode(entry[:crt])
    key = Chef::Nexus.decode(entry[:key])

    file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.crt" do
      content certificate
      mode    "077"
      action :create
    end

    file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.key" do
      content key
      mode    "077"
      action  :create
    end
  else
    log "Could not find ssl_certificate data bag, using default certificate." do
      level :warn
    end

    cookbook_file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.crt" do
      source "self_signed_cert.crt"
      mode   "077"
      action :create
    end

    cookbook_file "#{node[:nginx][:dir]}/shared/certificates/nexus-proxy.key" do
      source "self_signed_key.key"
      mode   "077"
      action :create
    end
  end
when :none
  log "Nexus is not being configured for SSL"
end
