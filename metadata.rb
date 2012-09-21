name             "nexus"
maintainer       "Riot Games"
maintainer_email "kallan@riotgames.com"
license          "Apache 2.0"
description      "Installs/Configures nexus"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.12.6"

%w{ ubuntu centos }.each do |os|
  supports os
end

depends "ark", "~> 0.0.11"
depends "java", "~> 1.5.2"
depends "nginx", "~> 1.0.0"
depends "bluepill", "~> 1.0.6"
