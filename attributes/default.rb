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
default[:nexus][:version]                                      = '2.3.0-04'
default[:nexus][:base_dir]                                      = '/'
default[:nexus][:user]                                         = 'nexus'
default[:nexus][:group]                                        = 'nexus'
default[:nexus][:url]                                          = "http://www.sonatype.org/downloads/nexus-#{node[:nexus][:version]}-bundle.tar.gz"
default[:nexus][:checksum]                                     = 'dab522ebd4f8e393b61f4aed32f7bfc67bbac6d67bf3cacaca8ee9db943274f0'

default[:nexus][:port]                                         = '8081'
default[:nexus][:host]                                         = '0.0.0.0'
default[:nexus][:context_path]                                 = '/nexus'

default[:nexus][:name]                                         = 'nexus'
default[:nexus][:bundle_name]                                  = "#{node[:nexus][:name]}-#{node[:nexus][:version]}"
default[:nexus][:home]                                         = "/usr/local/#{node[:nexus][:name]}"
default[:nexus][:pid_dir]                                      = "#{node[:nexus][:home]}/shared/pids"
default[:nexus][:work_dir]                                     = "/nexus/sonatype-work/nexus"

default[:nexus][:plugins]                                      = []

default[:nexus][:jetty][:loopback]                             = false

default[:nexus][:ssl][:jetty]                                  = false
default[:nexus][:ssl][:nginx]                                  = false
default[:nexus][:ssl][:jetty_keystore_path]                    = "#{node[:nexus][:home]}/shared/certs"
default[:nexus][:ssl][:verify]                                 = true
default[:nexus][:ssl][:port]                                   = 8443

default[:nexus][:ssl_certificate][:key]                        = node[:fqdn]
default[:nexus][:jetty_keystore][:key]                         = node[:fqdn]

default[:nexus][:nginx_proxy][:server_name]                    = node[:fqdn]

default[:nexus][:nginx][:server][:options]                     = {
  :client_max_body_size    => '200M',
  :client_body_buffer_size => '512k',
  :keepalive_timeout       => '0'
}

default[:nexus][:nginx][:proxy][:options]                      = {
  
}

default[:nexus][:cli][:repository]                             = "releases"
default[:nexus][:cli][:default_admin_credentials_updated]      = false
default[:nexus][:cli][:retries]                                = 3
default[:nexus][:cli][:retry_delay]                            = 10

default[:nexus][:mount][:nfs][:enable]                         = false
default[:nexus][:mount][:nfs][:mount_point]                    = "/mnt/nexus"
default[:nexus][:mount][:nfs][:device_path]                    = nil
