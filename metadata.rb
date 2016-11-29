name             "nexus"
maintainer       "Riot Games"
maintainer_email "kallan@riotgames.com"
license          "Apache 2.0"
description      "Installs/Configures nexus"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "3.3.2"

%w{ ubuntu centos }.each do |os|
  supports os
end

depends "java", ">= 1.15.4"
depends "chef_nginx", "~> 4.0.1"
depends "artifact", ">= 1.11.0"
