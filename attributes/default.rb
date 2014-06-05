#
# Cookbook Name:: nexus
# Attributes:: default
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
#

default[:java][:jdk_version] = '7'
# this duplicates logic from the java cookbook's attributes because
# we can't work around the attribute file load ordering
case node['platform_family']
when "rhel", "fedora"
  default['java']['java_home'] = "/usr/lib/jvm/java"
  default['java']['openjdk_packages'] = ["java-1.#{node['java']['jdk_version']}.0-openjdk", "java-1.#{node['java']['jdk_version']}.0-openjdk-devel"]
when "debian"
  default['java']['java_home'] = "/usr/lib/jvm/default-java"
  default['java']['openjdk_packages'] = ["openjdk-#{node['java']['jdk_version']}-jdk", "default-jre-headless"]
else
  default['java']['java_home'] = "/usr/lib/jvm/default-java"
  default['java']['openjdk_packages'] = ["openjdk-#{node['java']['jdk_version']}-jdk"]
end

default[:nexus][:version]                                      = '2.8.0-05'
default[:nexus][:base_dir]                                      = '/'
default[:nexus][:user]                                         = 'nexus'
default[:nexus][:group]                                        = 'nexus'
default[:nexus][:external_version]                             = '2.8.0'
default[:nexus][:url]                                          = "http://www.sonatype.org/downloads/nexus-#{node[:nexus][:external_version]}-bundle.tar.gz"
default[:nexus][:checksum]                                     = '9ccec9856922d2e5d4942feb9f7cdc8f73e75c79583e50b816650a02eff7045d'

default[:nexus][:port]                                         = '8081'
default[:nexus][:host]                                         = '0.0.0.0'
default[:nexus][:context_path]                                 = '/nexus'

default[:nexus][:name]                                         = 'nexus'
default[:nexus][:bundle_name]                                  = "#{node[:nexus][:name]}-#{node[:nexus][:version]}"
default[:nexus][:home]                                         = "/usr/local/#{node[:nexus][:name]}"
default[:nexus][:pid_dir]                                      = "#{node[:nexus][:home]}/shared/pids"
default[:nexus][:work_dir]                                     = "/nexus/sonatype-work/nexus"

default[:nexus][:app_server][:jetty][:loopback]                = false

default[:nexus][:app_server_proxy][:ssl][:port]                = 8443
default[:nexus][:app_server_proxy][:ssl][:key]                 = node[:fqdn]

default[:nexus][:app_server_proxy][:use_self_signed]  = false
default[:nexus][:app_server_proxy][:server_name]      = node[:fqdn]
default[:nexus][:app_server_proxy][:port]             = "http://127.0.0.1:#{node[:nexus][:port]}"
default[:nexus][:app_server_proxy][:server][:options] = [
  "client_max_body_size 200M",
  "client_body_buffer_size 512k",
  "keepalive_timeout 0"
]
default[:nexus][:app_server_proxy][:proxy][:options]  = []

default[:nexus][:load_balancer][:upstream_name] = "nexii"
default[:nexus][:load_balancer][:upstream_servers] = []

default[:nexus][:cli][:ssl][:verify]                           = true
default[:nexus][:cli][:repository]                             = "releases"
default[:nexus][:cli][:default_admin_credentials_updated]      = false
default[:nexus][:cli][:retries]                                = 3
default[:nexus][:cli][:retry_delay]                            = 10
  
default[:nexus][:use_chef_vault]                              = false
