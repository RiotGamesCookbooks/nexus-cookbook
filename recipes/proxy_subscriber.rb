#
# Cookbook Name:: nexus
# Recipe:: proxy_subscriber
#
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
search(:node, 'run_list:recipe\[nexus\:\:hosted_publisher\]') do |matching_node|
  hosted_repositories = matching_node[:nexus][:repository][:create_hosted]
  publishers = matching_node[:nexus][:repository][:publishers]
  hosted_publishers = hosted_repositories & publishers

  hosted_publishers.each do |repository|
    url = "#{matching_node[:fqdn]}:#{matching_node[:nexus][:nginx_proxy][:listen_port]}/nexus/content/content/repositories/#{repository.downcase}"
    nexus_repository repository do
      action   :create
      type     "proxy"
      url      url
    end

    nexus_repository repository do
      action      :update
      subscriber  true
    end
  end
end