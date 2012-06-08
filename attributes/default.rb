
default[:nexus][:port] = "8080"
default[:nexus][:home] = "/usr/local"
default[:nexus][:work] = "#{node[:nexus][:home]}/sonatype-work"
default[:nexus][:plugins][:rundeck][:version] = "1.2"
