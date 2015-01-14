name             "nexus"
maintainer       "Riot Games"
maintainer_email "kallan@riotgames.com"
license          "Apache 2.0"
description      "Installs/Configures nexus"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "3.3.1"

%w{ ubuntu centos }.each do |os|
  supports os
end

depends "java", ">= 1.15.4"
depends "nginx", ">= 1.8.0"
depends "artifact", ">= 1.11.0"
