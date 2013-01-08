name             "nexus"
maintainer       "Riot Games"
maintainer_email "kallan@riotgames.com"
license          "Apache 2.0"
description      "Installs/Configures nexus"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          IO.read(File.join(File.dirname(__FILE__), 'VERSION')) rescue "0.0.1"

%w{ ubuntu centos }.each do |os|
  supports os
end

depends "java", "~> 1.5.2"
depends "nginx", "~> 1.0.0"
depends "artifact", "~> 0.11.5"
depends "build-essential"
depends "yum"