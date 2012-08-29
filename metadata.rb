maintainer       "Riot Games"
maintainer_email "kallan@riotgames.com"
license          "Apache 2.0"
description      "Installs/Configures nexus"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.11.2"

%w{ ubuntu centos }.each do |os|
  supports os
end

depends "ark"
depends "java"
depends "nginx"
depends "bluepill"
