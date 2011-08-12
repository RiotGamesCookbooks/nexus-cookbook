#
# Cookbook Name:: maven
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
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
include_recipe "java"

remote_file "/tmp/nexus-oss-webapp-1.9.2-bundle.tar.gz" do  
source "http://nexus.sonatype.org/downloads/nexus-oss-webapp-1.9.2-bundle.tar.gz"  
mode "0644"  
end

script "install_nexus" do  
interpreter "bash"  
user "root"  
cwd "/tmp"  
code <<-EOH  
cd /usr/local
tar -xzvf /tmp/nexus-oss-webapp-1.9.2-bundle.tar.gz
ln -s /usr/local/nexus-oss-webapp-1.9.2 /usr/local/nexus
rm /usr/local/nexus/conf/plexus.properties
groupadd -g1230 nexus
useradd -u1230 -g1230 -M nexus
chown -R nexus:nexus /usr/local/nexus-oss-webapp-1.9.2/ /usr/local/sonatype-work/
EOH
end

template "/usr/local/nexus/conf/plexus.properties" do  
source "plexus.properties.erb"  
owner "nexus"
end

template "/etc/init.d/nexus" do  
source "nexus.erb"  
owner "root"
mode "0755"
end

execute "startservice" do  
command "service nexus start"   
end

