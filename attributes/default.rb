#
# Cookbook Name:: nexus
# Attributes:: default
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
#
default[:nexus][:version]                                      = '2.1.2'
default[:nexus][:user]                                         = 'nexus'
default[:nexus][:group]                                        = 'nexus'
default[:nexus][:url]                                          = "http://www.sonatype.org/downloads/nexus-#{node[:nexus][:version]}-bundle.tar.gz"

default[:nexus][:port]                                         = '8081'
default[:nexus][:host]                                         = '0.0.0.0'
default[:nexus][:context_path]                                 = '/nexus'

default[:nexus][:name]                                         = 'nexus'
default[:nexus][:bundle_name]                                  = "#{node[:nexus][:name]}-#{node[:nexus][:version]}"
default[:nexus][:home]                                         = "/usr/local/#{node[:nexus][:name]}"

default[:nexus][:current_path]                                 = "#{node[:nexus][:home]}/current/#{node[:nexus][:bundle_name]}"

default[:nexus][:conf_dir]                                     = "#{node[:nexus][:current_path]}/conf"
default[:nexus][:bin_dir]                                      = "#{node[:nexus][:current_path]}/bin"

default[:nexus][:work_dir]                                     = "/nexus/sonatype-work/nexus"

default[:nexus][:jetty][:loopback]                             = true

default[:nexus][:ssl][:verify]                                 = true
default[:nexus][:ssl_certificate][:key]                        = node[:fqdn]

default[:nexus][:nginx_proxy][:listen_port]                    = 8443
default[:nexus][:nginx_proxy][:server_name]                    = node[:fqdn]

default[:nexus][:plugins]                                      = ['nexus-custom-metadata-plugin']

default[:nexus][:nginx][:options][:client_max_body_size]       = '200M'
default[:nexus][:nginx][:options][:client_body_buffer_size]    = '512k'

default[:nexus][:cli][:url]                                    = "https://#{node[:nexus][:nginx_proxy][:server_name]}:#{node[:nexus][:nginx_proxy][:listen_port]}/nexus"
default[:nexus][:cli][:repository]                             = "releases"
default[:nexus][:cli][:packages]                               = ["libxml2-devel", "libxslt-devel"]

default[:nexus][:smart_proxy][:enable]                         = true
default[:nexus][:smart_proxy][:host]                           = nil
default[:nexus][:smart_proxy][:port]                           = nil

default[:nexus][:mount][:nfs][:enable]                         = false
default[:nexus][:mount][:nfs][:mount_point]                    = "/mnt/nexus"
default[:nexus][:mount][:nfs][:device_path]                    = nil
default[:nexus][:mount][:nfs][:non_mount_dir][:indexer]        = "/nexus/indexer"
default[:nexus][:mount][:nfs][:non_mount_dir][:timeline]       = "/nexus/timeline"